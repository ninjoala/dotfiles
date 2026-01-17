---
name: vikunja
description: This skill should be used when the user asks to "check vikunja", "check my tasks", "show tasks", "add task", "update task", "complete task", mentions "Vikunja", or discusses task management in the todo.dobosprime.com system.
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

### 1. List Tasks in a Project

```bash
~/.claude-config/plugins/personal/scripts/vikunja-api.sh list-tasks 3
```

### 2. Create a New Task

```bash
~/.claude-config/plugins/personal/scripts/vikunja-api.sh create-task 3 "Task title here" "Optional description"
```

### 3. Update a Task (Mark as Done)

```bash
~/.claude-config/plugins/personal/scripts/vikunja-api.sh update-task 22 true
```

### 4. List All Projects

```bash
~/.claude-config/plugins/personal/scripts/vikunja-api.sh list-projects
```

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
3. **Provide context** when listing tasks (show title, done status, ID)
4. **Confirm actions** before creating/updating tasks
5. **Handle errors gracefully** and inform the user if API calls fail
6. **Pipe to jq** for formatted output: `vikunja-api.sh list-tasks 3 | jq`

## Example Workflows

### Show all Boosted tasks
1. Fetch token from secrets file
2. Call `/api/v1/projects/3/tasks`
3. Parse JSON and present in readable format
4. Show: ID, title, completion status

### Add task to Boosted project
1. Confirm task details with user
2. Fetch token from secrets file
3. POST to `/api/v1/projects/3/tasks` with title and description
4. Confirm task creation with returned ID

### Mark task as complete
1. User provides task ID or title
2. If title provided, fetch tasks to find ID
3. POST update with `"done": true`
4. Confirm completion

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
