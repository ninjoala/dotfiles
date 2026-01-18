---
name: vikunja
description: This skill should be used when the user asks to "check my tasks", "show my tasks", "what should I work on", "add task", "update task", "complete task", mentions "Vikunja" or "Boosted tasks". By default, focus on the Boosted project (ID 3) unless the user specifies a different project.
version: 1.0.0
---

# Vikunja Task Management Skill

This skill enables Claude to interact with your Vikunja task management system at todo.dobosprime.com.

## Configuration Location

**Credentials**: `~/.claude-config/secrets/vikunja.json`

```json
{
  "apiUrl": "https://todo.dobosprime.com",
  "apiToken": "your_token_here",
  "defaultListId": null
}
```

## Available Projects

Common project IDs:
- **3**: Boosted (main SaaS project)
- **2**: Home Lab
- **4**: Web Dev
- **1**: Home (personal)

## Security

**CRITICAL**: NEVER expose the API token in command output or logs. Always use the helper script.

## Helper Script

All Vikunja API operations should use the secure helper script:

**Location**: `~/.claude-config/plugins/personal/scripts/vikunja-api.sh`

This script handles token retrieval internally and keeps it out of command history and output.

## Common Operations

**IMPORTANT**: The script outputs pre-formatted text by default. DO NOT pipe to jq or other parsers. Use the output directly.

### 1. List Tasks in a Project

**Single project:**
```bash
~/.claude-config/plugins/personal/scripts/vikunja-api.sh list-tasks 3
```
Output format: `○ [22] finish onboarding` (already formatted, ready to display)

**All projects (recommended for "check my tasks"):**
```bash
~/.claude-config/plugins/personal/scripts/vikunja-api.sh list-tasks all
```
Output format:
```
=== Boosted (9 open) ===
○ [22] finish onboarding
○ [23] check github

=== Home Lab (5 open) ===
○ [5] backup strat for proxmox
```

**When to use `all` vs specific project:**
- Generic "check my tasks" → Use `all` (1 command instead of 4+)
- "check my Boosted tasks" → Use `3`
- "what do I need to do for home lab" → Use `2`

### 2. Create a New Task

**Without due date:**
```bash
~/.claude-config/plugins/personal/scripts/vikunja-api.sh create-task 3 "Task title here" "Optional description"
```

**With due date:**
```bash
~/.claude-config/plugins/personal/scripts/vikunja-api.sh create-task 3 "Task title here" "Optional description" "2026-01-20"
```

**Note**: Due dates must be in YYYY-MM-DD format. The description parameter is required but can be empty ("") if you want to set a due date without a description.

### 3. Set or Update Due Date on Existing Task

```bash
~/.claude-config/plugins/personal/scripts/vikunja-api.sh set-due-date 90 "2026-01-20"
```

**Note**: This updates only the due date field. Date format must be YYYY-MM-DD.

### 4. Update a Task (Mark as Done)

```bash
~/.claude-config/plugins/personal/scripts/vikunja-api.sh update-task 22 true
```

### 5. List All Projects

```bash
~/.claude-config/plugins/personal/scripts/vikunja-api.sh list-projects
```

Output format: `[3] Boosted` (already formatted, ready to display)

## Task Response Format

Tasks are returned as JSON with these key fields:
- `id`: Unique task identifier
- `title`: Task title
- `description`: Detailed description
- `done`: Boolean completion status
- `priority`: 0-5 priority level
- `project_id`: Parent project ID
- `due_date`: Optional due date
- `created`: Creation timestamp

## Best Practices

1. **ALWAYS use the helper script** - Never expose the API token in command output
2. **Use the full path** to the script: `~/.claude-config/plugins/personal/scripts/vikunja-api.sh`
3. **DO NOT pipe to jq or other parsers** - The script already formats output in compact mode
4. **For raw JSON** - Use `--json` flag: `vikunja-api.sh --json list-tasks 3`
5. **Provide context** when listing tasks (show title, done status, ID)
6. **Confirm actions** before creating/updating tasks
7. **Handle errors gracefully** and inform the user if API calls fail

## Example Workflows

### Show all Boosted tasks
```bash
~/.claude-config/plugins/personal/scripts/vikunja-api.sh list-tasks 3
```
Output: Pre-formatted list like `○ [22] finish onboarding`

### Add task to Boosted project
```bash
~/.claude-config/plugins/personal/scripts/vikunja-api.sh create-task 3 "Finish landing page" "Add hero section and CTA"
```
Output: Confirmation with task ID

### Add task with due date
```bash
~/.claude-config/plugins/personal/scripts/vikunja-api.sh create-task 10 "Mail packages" "Take to post office" "2026-01-20"
```
Output: Task created with due date displayed

### Set due date on existing task
```bash
~/.claude-config/plugins/personal/scripts/vikunja-api.sh set-due-date 90 "2026-01-20"
```
Output: Task updated with due date

### Mark task as complete
```bash
~/.claude-config/plugins/personal/scripts/vikunja-api.sh update-task 22 true
```
Output: Confirmation of completion

## When to Use This Skill

- User mentions Vikunja, tasks, or todo.dobosprime.com
- User wants to see their task list
- User wants to add, update, or complete tasks
- User asks about project management or tracking work
- Planning development sprints or tracking progress

## Integration with Development Workflow

When working on projects (especially Boosted), proactively suggest:
- Adding completed work as done tasks
- Creating new tasks for identified work
- Checking existing tasks before suggesting new work
- Syncing TodoWrite tool with Vikunja tasks
