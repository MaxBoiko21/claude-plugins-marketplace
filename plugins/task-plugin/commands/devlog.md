---
description: Create DevLog entry in Notion for last commit
allowed-tools: Bash(cat ~/.claude/notion-databases.md), Bash(git *), Bash(basename *), mcp__plugin_Notion_notion__*
model: sonnet
---

<last_commit>
!`git log -1 --pretty=format:'%H|%s|%ad' --date=short`
</last_commit>

<diff_stats>
!`git diff HEAD~1 --stat 2>/dev/null | tail -50`
</diff_stats>

<diff_summary>
!`git diff HEAD~1 --shortstat 2>/dev/null`
</diff_summary>

<remote_url>
!`git remote get-url origin 2>/dev/null || echo ""`
</remote_url>

<repo_name>
!`basename $(git rev-parse --show-toplevel 2>/dev/null)`
</repo_name>

You are a DevLog assistant. Create a Notion DevLog entry for the last commit.

## Step 0: Load Notion config
Run `cat ~/.claude/notion-databases.md` to read the config file. Parse database IDs from the YAML frontmatter:
- `projects` → Projects DB ID
- `devlog` → DevLog DB ID

If the file doesn't exist or IDs are missing, tell the user to create `~/.claude/notion-databases.md` with their DB IDs and stop.

## Parse commit data

From `<last_commit>`, split by `|` to get: commit hash, commit message, commit date.
From `<remote_url>`, extract `owner/repo` path (strip `https://github.com/` or `git@github.com:` prefix and `.git` suffix). Construct commit URL: `https://github.com/{owner}/{repo}/commit/{hash}`.
If remote URL is empty, use `<repo_name>` as the repo name, and skip commit URL.

## Extra context from user

$ARGUMENTS

## Instructions

### Step 1: Classify type from commit prefix
Map the conventional commit prefix:
- feat → Feature
- fix → Bug
- refactor → Refactor
- hotfix → Hotfix
- anything else → Feature

### Step 2: Find or create project
Search the Projects database (Projects DB ID from above) for a page whose Name (title) matches the repo name (case-insensitive).
- If found, note its page ID.
- If NOT found, create a new page in Projects DB with Name = repo name, Status = "Active". Note its page ID.

### Step 3: Query related logs
Query the DevLog database (DevLog DB ID from above) filtered by Project relation matching the project page ID, sorted by Date descending, limit 100.
From results, identify entries whose Name or Summary relates to the same topic/feature as this commit. Collect their page IDs (max 5 related).

### Step 4: Create DevLog entry
Create a new page in the DevLog database (DevLog DB ID from above).

**Properties:**
- **Name** (title): Derive from commit message — strip the conventional prefix (feat:, fix:, etc.), capitalize first letter. Keep concise.
- **Project** (relation): Use the Notion page URL of the project (e.g. `https://www.notion.so/<page_id_without_dashes>`)
- **Type** (select): The classified type from Step 1. Use Hotfix only for urgent production fixes, Refactor for non-functional changes, Bug for defect corrections, Feature for new functionality.
- **Date** (date): { "start": "<commit_date>" }
- **Summary** (rich_text): 1-2 sentences, readable at a glance in a table view. If user provided extra context via $ARGUMENTS, incorporate it.
- **AI Estimate** (number): Honest estimate in hours (round to 0.25). Base on diff complexity and scope. Don't be optimistic.
- **Actual Hours** (number): Leave empty — user fills this manually.
- **Commit/PR** (url): The constructed commit URL (skip if no remote)
- **Related Logs** (relation): Array of related page IDs from Step 3 (skip if none found)

**Page body** — add two sections as content blocks:

```
## Problem
[2-4 sentences: what was wrong or what was needed. Include root cause if it's a bug.]

## Solution
[2-4 sentences: what was done. Mention key files or architectural decisions if relevant.]
```

### Writing guidelines
- English, technical, concise, factual. No fluff.
- Summary should be one line ideally.
- Problem and Solution should be self-contained — someone reading months later should understand without looking at code.

### Step 5: Output
Print: **DevLog created:** [Name] ([Type]) — [Summary first sentence]
