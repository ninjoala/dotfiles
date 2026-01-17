#!/bin/bash
# Vikunja API helper - keeps token out of command history and output
# Supports compact output format to save context

set -e

SECRETS_FILE="${HOME}/.claude-config/secrets/vikunja.json"
API_URL="https://todo.dobosprime.com/api/v1"

# Default format: compact (saves context), use --json for raw JSON
FORMAT="compact"

# Check for format flag
if [[ "$1" == "--json" ]]; then
    FORMAT="json"
    shift
fi

# Read token securely
if [ ! -f "$SECRETS_FILE" ]; then
    echo "Error: Vikunja secrets file not found at $SECRETS_FILE" >&2
    exit 1
fi

TOKEN=$(grep -o '"apiToken": *"[^"]*"' "$SECRETS_FILE" | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo "Error: Could not extract API token from $SECRETS_FILE" >&2
    exit 1
fi

# Helper function to format task list output
format_tasks() {
    if [[ "$FORMAT" == "json" ]]; then
        cat  # Pass through raw JSON
    else
        # Compact format - extract only essential fields
        python3 -c '
import sys, json
tasks = json.load(sys.stdin)
for t in tasks:
    status = "✓" if t["done"] else "○"
    tid = t["id"]
    title = t["title"]
    print(f"{status} [{tid}] {title}")
'
    fi
}

# Helper function to format single task output
format_task() {
    if [[ "$FORMAT" == "json" ]]; then
        cat  # Pass through raw JSON
    else
        python3 -c '
import sys, json
t = json.load(sys.stdin)
status = "✓ Done" if t["done"] else "○ Open"
tid = t["id"]
title = t["title"]
print(f"Task [{tid}] {status}: {title}")
desc = t.get("description")
if desc:
    print(f"  Description: {desc}")
'
    fi
}

# Execute API call based on command
case "$1" in
    list-tasks)
        PROJECT_ID="${2:-3}"
        curl -s "${API_URL}/projects/${PROJECT_ID}/tasks" \
            -H "Authorization: Bearer $TOKEN" | format_tasks
        ;;

    create-task)
        PROJECT_ID="${2:-3}"
        TITLE="$3"
        DESCRIPTION="${4:-}"

        if [ -z "$TITLE" ]; then
            echo "Error: Task title required" >&2
            echo "Usage: $0 create-task [project_id] \"title\" [\"description\"]" >&2
            exit 1
        fi

        curl -s "${API_URL}/projects/${PROJECT_ID}/tasks" \
            -H "Authorization: Bearer $TOKEN" \
            -H "Content-Type: application/json" \
            -d "{\"title\": \"$TITLE\", \"description\": \"$DESCRIPTION\"}" | format_task
        ;;

    update-task)
        TASK_ID="$2"
        DONE="${3:-true}"

        if [ -z "$TASK_ID" ]; then
            echo "Error: Task ID required" >&2
            echo "Usage: $0 update-task <task_id> [true|false]" >&2
            exit 1
        fi

        curl -s -X POST "${API_URL}/tasks/${TASK_ID}" \
            -H "Authorization: Bearer $TOKEN" \
            -H "Content-Type: application/json" \
            -d "{\"done\": $DONE}" | format_task
        ;;

    list-projects)
        curl -s "${API_URL}/projects" \
            -H "Authorization: Bearer $TOKEN" | \
        if [[ "$FORMAT" == "json" ]]; then
            cat
        else
            python3 -c '
import sys, json
projects = json.load(sys.stdin)
for p in projects:
    if p["id"] > 0:  # Skip special projects
        pid = p["id"]
        ptitle = p["title"]
        print(f"[{pid}] {ptitle}")
'
        fi
        ;;

    *)
        echo "Vikunja API Helper"
        echo ""
        echo "Usage:"
        echo "  $0 [--json] list-tasks [project_id]           - List tasks (default: 3)"
        echo "  $0 [--json] create-task [project_id] \"title\" [\"desc\"] - Create task"
        echo "  $0 [--json] update-task <task_id> [true|false] - Update task"
        echo "  $0 [--json] list-projects                      - List projects"
        echo ""
        echo "Options:"
        echo "  --json    Output raw JSON (default: compact format to save context)"
        echo ""
        echo "Examples:"
        echo "  $0 list-tasks 3              # Compact: ○ [22] finish onboarding"
        echo "  $0 --json list-tasks 3       # Full JSON for piping to jq"
        echo "  $0 create-task 3 \"Finish landing page\""
        echo "  $0 update-task 22 true"
        exit 1
        ;;
esac
