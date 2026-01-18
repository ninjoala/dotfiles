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
from datetime import datetime

tasks = json.load(sys.stdin)
for t in tasks:
    status = "✓" if t["done"] else "○"
    tid = t["id"]
    title = t["title"]

    # Build output line
    line = f"{status} [{tid}] {title}"

    # Add due date if set
    due_date = t.get("due_date", "")
    if due_date and due_date != "0001-01-01T00:00:00Z":
        dt = datetime.fromisoformat(due_date.replace("Z", "+00:00"))
        date_str = dt.strftime("%Y-%m-%d")
        line += f" (Due: {date_str})"

    print(line)

    # Add description if present
    desc = t.get("description", "").strip()
    if desc:
        print(f"    Note: {desc}")
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

        if [[ "$PROJECT_ID" == "all" ]]; then
            # Fetch all projects first
            PROJECTS=$(curl -s "${API_URL}/projects" -H "Authorization: Bearer $TOKEN")

            # Loop through each project and show tasks
            echo "$PROJECTS" | TOKEN="$TOKEN" API_URL="$API_URL" python3 -c '
import sys, json, subprocess, os

projects = json.load(sys.stdin)
token = os.environ["TOKEN"]
api_url = os.environ["API_URL"]

for p in projects:
    if p["id"] > 0:  # Skip special projects
        # Fetch tasks for this project
        import urllib.request
        project_id = p["id"]
        project_title = p["title"]
        url = f"{api_url}/projects/{project_id}/tasks"

        req = urllib.request.Request(
            url,
            headers={"Authorization": f"Bearer {token}"}
        )

        try:
            with urllib.request.urlopen(req) as response:
                tasks = json.load(response)
                open_tasks = [t for t in tasks if not t["done"]]

                if open_tasks:
                    print(f"\n=== {project_title} ({len(open_tasks)} open) ===")
                    for t in open_tasks:
                        task_id = t["id"]
                        task_title = t["title"]

                        # Build output line
                        line = f"○ [{task_id}] {task_title}"

                        # Add due date if set
                        due_date = t.get("due_date", "")
                        if due_date and due_date != "0001-01-01T00:00:00Z":
                            from datetime import datetime
                            dt = datetime.fromisoformat(due_date.replace("Z", "+00:00"))
                            date_str = dt.strftime("%Y-%m-%d")
                            line += f" (Due: {date_str})"

                        print(line)

                        # Add description if present
                        desc = t.get("description", "").strip()
                        if desc:
                            print(f"    Note: {desc}")
        except Exception as e:
            print(f"Error fetching tasks for {project_title}: {e}", file=sys.stderr)
'
        else
            curl -s "${API_URL}/projects/${PROJECT_ID}/tasks" \
                -H "Authorization: Bearer $TOKEN" | format_tasks
        fi
        ;;

    create-task)
        PROJECT_ID="${2:-3}"
        TITLE="$3"
        DESCRIPTION="${4:-}"
        DUE_DATE="${5:-}"

        if [ -z "$TITLE" ]; then
            echo "Error: Task title required" >&2
            echo "Usage: $0 create-task [project_id] \"title\" [\"description\"] [\"due_date\"]" >&2
            exit 1
        fi

        # Build JSON payload
        JSON_DATA="{\"title\": \"$TITLE\", \"description\": \"$DESCRIPTION\""

        # Add due date if provided (expects YYYY-MM-DD format, converts to RFC3339)
        if [ -n "$DUE_DATE" ]; then
            # Convert YYYY-MM-DD to RFC3339 format (end of day in UTC)
            DUE_RFC3339="${DUE_DATE}T23:59:59Z"
            JSON_DATA="$JSON_DATA, \"due_date\": \"$DUE_RFC3339\""
        fi

        JSON_DATA="$JSON_DATA}"

        curl -s -X PUT "${API_URL}/projects/${PROJECT_ID}/tasks" \
            -H "Authorization: Bearer $TOKEN" \
            -H "Content-Type: application/json" \
            -d "$JSON_DATA" | format_task
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

    set-due-date)
        TASK_ID="$2"
        DUE_DATE="$3"

        if [ -z "$TASK_ID" ] || [ -z "$DUE_DATE" ]; then
            echo "Error: Task ID and due date required" >&2
            echo "Usage: $0 set-due-date <task_id> <YYYY-MM-DD>" >&2
            exit 1
        fi

        # Convert YYYY-MM-DD to RFC3339 format (end of day in UTC)
        DUE_RFC3339="${DUE_DATE}T23:59:59Z"

        curl -s -X POST "${API_URL}/tasks/${TASK_ID}" \
            -H "Authorization: Bearer $TOKEN" \
            -H "Content-Type: application/json" \
            -d "{\"due_date\": \"$DUE_RFC3339\"}" | format_task
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
        echo "  $0 [--json] list-tasks [project_id|all]                    - List tasks (default: 3, use 'all' for all projects)"
        echo "  $0 [--json] create-task [project_id] \"title\" [\"desc\"] [\"YYYY-MM-DD\"] - Create task with optional due date"
        echo "  $0 [--json] update-task <task_id> [true|false]             - Update task completion status"
        echo "  $0 [--json] set-due-date <task_id> <YYYY-MM-DD>            - Set or update task due date"
        echo "  $0 [--json] list-projects                                  - List projects"
        echo ""
        echo "Options:"
        echo "  --json    Output raw JSON (default: compact format to save context)"
        echo ""
        echo "Examples:"
        echo "  $0 list-tasks 3                                  # Boosted project: ○ [22] finish onboarding"
        echo "  $0 list-tasks all                                # All projects with headers"
        echo "  $0 --json list-tasks 3                           # Full JSON for piping to jq"
        echo "  $0 create-task 3 \"Finish landing page\""
        echo "  $0 create-task 3 \"Mail packages\" \"\" \"2026-01-20\"  # Task with due date"
        echo "  $0 set-due-date 90 \"2026-01-20\"                  # Set due date on existing task"
        echo "  $0 update-task 22 true                           # Mark task as done"
        exit 1
        ;;
esac
