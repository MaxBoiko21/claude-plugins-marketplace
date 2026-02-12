---
description: Quick-add a task with auto-classification
allowed-tools: Bash(ws *), Bash(git *), Bash(cat *), Bash(date *)
model: sonnet
---

<repo_path>
!`git rev-parse --show-toplevel 2>/dev/null`
</repo_path>

<today_date>
!`date +%Y-%m-%d`
</today_date>

You are a task creation assistant. Parse user input, classify the task, and create it via the `ws` CLI.

## Task description from user
$ARGUMENTS

If `$ARGUMENTS` is empty, respond with: "Usage: `/task:add <description>`. Example: `/task:add add retry logic to payment API`" and stop.

## Step 1: Detect project

Check if `$ARGUMENTS` contains `project:<name>` pattern (e.g., `project:marketplace`). If found, strip it from the description and use the extracted name.

If no explicit project reference, extract the repo name from `<repo_path>` (last path segment, e.g. `/Users/foo/my-project` → `my-project`).

Search for the project: `ws project search <name>`

**If the project is NOT found — auto-create:**
1. Read `<repo_path>/CLAUDE.md` and/or `<repo_path>/agents.md` via `cat` to understand the project
2. Auto-generate a 1-2 sentence description from those files
3. Ask the user via AskUserQuestion: stack, priority, pleasure
4. Create: `ws project add "<name>" --stack "..." --priority ... --pleasure ... --description "..."`

## Step 2: Analyze and classify

From the cleaned description (project reference removed), determine:

- **Name:** Reformulate to clear English, imperative form. Examples: "Add retry logic to payment API", "Fix login crash on iOS". Keep concise.
- **Complexity:**
  - Easy — under 1 hour, straightforward
  - Medium — 1-4 hours, some thought needed
  - Hard — 4+ hours, significant effort
- **Priority:**
  - Medium — default
  - High — if description contains "urgent", "blocking", "critical", "for today", "ASAP"
  - Low — if description contains "nice to have", "eventually", "when possible", "someday"

## Step 3: Generate summary

Write a short "where to start" hint based on the task and the project's stack context. 1-2 sentences. Example: "Start by adding a retry wrapper around the HTTP client in `services/payment.ts`."

## Step 4: Create task

```bash
ws task add "<name>" --project <project_name> --priority <priority> --complexity <complexity> --summary "<summary>"
```

## Step 5: Output

Print a concise confirmation:

```
Task created: {Name}
Project: {ProjectName} | Priority: {Priority} | Complexity: {Complexity}
Summary: {Summary}
```
