---
description: Project task overview with DevLog context and suggestions
allowed-tools: Bash(cat ~/.claude/notion-databases.md), Bash(git *), mcp__plugin_Notion_notion__*
model: sonnet
---

<repo_path>
!`git rev-parse --show-toplevel 2>/dev/null`
</repo_path>

<current_branch>
!`git branch --show-current 2>/dev/null`
</current_branch>

You are a project task analyst. Show an overview of tasks for the current project with context from recent DevLog entries.

## Step 0: Load Notion config
Run `cat ~/.claude/notion-databases.md` to read the config file. Parse database IDs from the YAML frontmatter:
- `tasks` → Tasks DB ID
- `projects` → Projects DB ID
- `devlog` → DevLog DB ID

If the file doesn't exist or IDs are missing, tell the user to create `~/.claude/notion-databases.md` with their DB IDs and stop.

## Optional focus area from user
$ARGUMENTS

## Step 1: Detect project

Extract the repo name from `<repo_path>` (last path segment, e.g. `/Users/foo/my-project` → `my-project`).

Search the Projects DB for a page whose Name matches the repo name (case-insensitive). If not found, report "Project not found for repo: {repo_name}" and stop.

Note the project's page ID.

## Step 2: Fetch project tasks

Query the Tasks DB filtered by:
- Project relation matches the project page ID
- Status ≠ "Done"

Sort results by Priority (High → Medium → Low), then by Date ascending.

## Step 3: Fetch recent DevLog entries

Query the DevLog DB filtered by Project relation matching the project page ID, sorted by Date descending, limit 5.

## Step 4: Analyze

- If `$ARGUMENTS` is provided, filter or highlight tasks matching the focus area.
- Detect potential dependencies between tasks (e.g., task A mentions something task B produces).
- Check for conflicts: is there a task that overlaps with something already logged in DevLog?
- Suggest ordering improvements if obvious (e.g., a "Hard" task blocking multiple others should come first).

## Step 5: Output

Format as:

```
## Tasks — [ProjectName]
Branch: {current_branch}

### High Priority
- [ ] Task name — Complexity, ~estimate
  Dependency info (if any)

### Medium Priority
- [ ] Task name — Complexity, ~estimate

### Low Priority
- [ ] Task name — Complexity, ~estimate

### Recent DevLog (last 5)
- {date}: {name} ({type}) — {summary first sentence}

### Suggestions
- Ordering, dependency, or conflict observations
```

Rules:
- If a priority group is empty, omit it.
- If no tasks found, say "No open tasks for {ProjectName}."
- Keep suggestions actionable and brief. Skip if nothing useful to say.
