# Custom Agent Usage Examples

This document shows how to use custom agents defined in this directory.

## GitHub Issue Planner Agent

### What It Does

The `github-issue-planner` agent is an expert at:
- Fetching GitHub issues using the `gh` CLI
- Parsing issue content (description, acceptance criteria, comments)
- Extracting actionable tasks
- Creating implementation plans
- Identifying dependencies between issues
- Suggesting optimal work order

### How to Invoke

Use the Task tool with `subagent_type="github-issue-planner"`:

```
User: "Parse issue #123 and create actionable tasks"

Claude: [Invokes Task tool with subagent_type="github-issue-planner"]
```

### Example Use Cases

#### 1. Parse Single Issue

**User request:**
```
"Analyze GitHub issue #456 and break it down into tasks"
```

**What happens:**
- Agent fetches issue using `gh issue view 456 --json ...`
- Parses title, body, labels, comments, acceptance criteria
- Extracts actionable tasks
- Creates structured breakdown with:
  - Context summary
  - Key requirements
  - Hierarchical task list (setup → implementation → testing → docs)
  - Dependencies
  - Suggested implementation order
- Offers to add tasks to TodoWrite tool

#### 2. Sprint Planning from Multiple Issues

**User request:**
```
"Break down issues #10, #11, and #12 into a sprint plan"
```

**What happens:**
- Agent fetches all three issues
- Analyzes each individually
- Identifies cross-issue dependencies
- Creates unified sprint plan with:
  - Prioritization (high/medium/low)
  - Complexity estimates
  - Recommended work order
  - Parallelization opportunities
- Suggests which issue to start with and why

#### 3. Parse Issue from URL

**User request:**
```
"Parse this issue: https://github.com/myorg/myrepo/issues/789"
```

**What happens:**
- Agent fetches issue from provided URL
- Creates detailed task breakdown
- Includes file/component references when mentioned in issue
- Flags any unclear requirements

#### 4. Pull Request Review Planning

**User request:**
```
"What needs to be reviewed in PR #55?"
```

**What happens:**
- Agent fetches PR details including files, commits, reviews
- Analyzes changes and review comments
- Creates review checklist:
  - Files to examine carefully
  - Specific concerns from comments
  - Test coverage to verify
  - Documentation to check

### Output Format

The agent produces structured markdown like this:

```markdown
## Issue #123: Add User Authentication

**Context**: Users need ability to sign up and log in to access personalized features

**Key Requirements**:
- JWT-based authentication
- Email/password login
- Protected API routes
- Session management

**Action Items**:

### Setup & Investigation
- [ ] Review existing auth patterns in codebase (src/middleware/)
- [ ] Set up JWT library and configuration

### Core Implementation
- [ ] Create POST /api/auth/signup endpoint in src/routes/auth.ts
- [ ] Create POST /api/auth/login endpoint in src/routes/auth.ts
- [ ] Implement JWT token generation in src/utils/jwt.ts
- [ ] Add auth middleware in src/middleware/auth.ts
- [ ] Protect user routes with auth middleware

### Testing
- [ ] Write unit tests for auth endpoints
- [ ] Test JWT token validation
- [ ] Test protected route access
- [ ] Test invalid credentials handling

### Documentation & Cleanup
- [ ] Update API docs with auth endpoints
- [ ] Add authentication guide to README
- [ ] Code review and refinement

**Dependencies**: None

**Suggested Order**: Start with middleware research, then implement core auth flow, then protect routes, finally add comprehensive tests
```

### Integration with TodoWrite

After parsing issues, the agent offers:

```
"Would you like me to add these tasks to your TodoWrite list to track progress?"
```

If you agree, tasks are formatted for TodoWrite with:
- **content**: "Implement user authentication" (imperative form)
- **activeForm**: "Implementing user authentication" (present continuous form)

### When to Use This Agent

Use `github-issue-planner` when:
- Starting work on a GitHub issue and need clear tasks
- Planning a sprint from multiple issues
- Breaking down complex issues into manageable pieces
- Understanding what a poorly-written issue is asking for
- Preparing for a PR review
- Need to identify dependencies between issues

### Tips for Best Results

1. **Provide issue numbers or URLs** - Agent will fetch the latest data
2. **Mention specific repository** if not in current directory
3. **Ask for sprint planning** when dealing with multiple issues
4. **Request TodoWrite integration** to track tasks
5. **Ask clarifying questions** if agent flags unclear requirements

### Behind the Scenes

The agent uses:
- `gh` CLI for GitHub API access (handles auth automatically)
- Pattern matching for common issue structures
- TodoWrite tool for task management integration
- Bash for running gh commands
- Read/Grep for examining codebase when referenced in issues

### Available Across All Projects

Because this agent is defined in your personal plugin at:
```
~/.claude-config/plugins/personal/agents/github-issue-planner.md
```

It's available in ANY directory where you run Claude Code. Your dotfiles ensure this follows you across machines.
