#!/bin/bash

# PostToolUse hook: create Notion DevLog entry after successful git commit
# Spawns background Claude process — exits immediately (non-blocking)

set -euo pipefail

INPUT=$(cat)

# Only trigger on Bash tool
TOOL_NAME="${TOOL_NAME:-}"
if [[ "$TOOL_NAME" != "Bash" ]]; then
  exit 0
fi

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
OUTPUT=$(echo "$INPUT" | jq -r '.tool_output // empty')

# Gate: must be a git commit (not amend), must have succeeded
if [[ -z "$COMMAND" ]] || ! echo "$COMMAND" | grep -q 'git commit'; then
  exit 0
fi
if echo "$COMMAND" | grep -q '\-\-amend'; then
  exit 0
fi
# Success pattern: git outputs "[branch hash]" on successful commit
if ! echo "$OUTPUT" | grep -qE '^\[.+ [a-f0-9]+\]'; then
  exit 0
fi

# Extract commit data
COMMIT_HASH=$(git rev-parse HEAD 2>/dev/null) || exit 0
COMMIT_MSG=$(git log -1 --pretty=format:'%s' 2>/dev/null) || exit 0
COMMIT_DATE=$(git log -1 --pretty=format:'%Y-%m-%d' 2>/dev/null) || exit 0
DIFF_STATS=$(git diff HEAD~1 --stat 2>/dev/null | tail -50) || DIFF_STATS=""
DIFF_SUMMARY=$(git diff HEAD~1 --shortstat 2>/dev/null) || DIFF_SUMMARY=""

# Get remote URL and derive repo info
REMOTE_URL=$(git remote get-url origin 2>/dev/null) || REMOTE_URL=""
if [[ -n "$REMOTE_URL" ]]; then
  # Extract owner/repo from SSH or HTTPS URL
  REPO_PATH=$(echo "$REMOTE_URL" | sed -E 's#^(https?://github\.com/|git@github\.com:)##; s/\.git$//')
  REPO_NAME=$(basename "$REPO_PATH")
  COMMIT_URL="https://github.com/${REPO_PATH}/commit/${COMMIT_HASH}"
else
  REPO_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
  COMMIT_URL=""
fi

NOTION_CONFIG="$HOME/.claude/notion-databases.md"
if [[ ! -f "$NOTION_CONFIG" ]]; then
  exit 0
fi
PROJECTS_DB=$(grep '^projects:' "$NOTION_CONFIG" | sed 's/projects: *"\{0,1\}\([^"]*\)"\{0,1\}/\1/')
DEVLOG_DB=$(grep '^devlog:' "$NOTION_CONFIG" | sed 's/devlog: *"\{0,1\}\([^"]*\)"\{0,1\}/\1/')
if [[ -z "$PROJECTS_DB" || -z "$DEVLOG_DB" ]]; then
  exit 0
fi

PROMPT=$(cat <<PROMPT_EOF
You are a DevLog assistant. Create a Notion DevLog entry for this commit.

## Commit Data
- Hash: ${COMMIT_HASH}
- Message: ${COMMIT_MSG}
- Date: ${COMMIT_DATE}
- Repo: ${REPO_NAME}
- Commit URL: ${COMMIT_URL}

## Diff Stats
${DIFF_STATS}

${DIFF_SUMMARY}

## Instructions

### Step 1: Classify type from commit prefix
Map the conventional commit prefix:
- feat → Feature
- fix → Bug
- refactor → Refactor
- hotfix → Hotfix
- anything else → Feature

### Step 2: Find or create project
Search the Projects database (ID: ${PROJECTS_DB}) for a page whose Name (title) matches "${REPO_NAME}" (case-insensitive).
- If found, note its page ID.
- If NOT found, create a new page in Projects DB with Name = "${REPO_NAME}", Status = "Active". Note its page ID.

### Step 3: Query related logs
Query the DevLog database (ID: ${DEVLOG_DB}) filtered by Project relation matching the project page ID, sorted by Date descending, limit 100.
From results, identify entries whose Name or Summary relates to the same topic/feature as this commit. Collect their page IDs (max 5 related).

### Step 4: Create DevLog entry
Create a new page in DevLog database (ID: ${DEVLOG_DB}).

Properties:
- Name (title): Derive from commit message — strip the conventional prefix (feat:, fix:, etc.), capitalize first letter. Keep concise.
- Project (relation): [{ "id": "<project_page_id>" }]
- Type (select): The classified type from Step 1. Use Hotfix only for urgent production fixes, Refactor for non-functional changes, Bug for defect corrections, Feature for new functionality.
- Date (date): { "start": "${COMMIT_DATE}" }
- Summary (rich_text): 1-2 sentences, readable at a glance. Technical, concise, factual.
- AI Estimate (number): Honest estimate in hours (round to 0.25). Base on diff complexity and scope.
- Actual Hours (number): Leave empty.
- Commit/PR (url): "${COMMIT_URL}" (skip if empty)
- Related Logs (relation): Array of related page IDs from Step 3 (skip if none found)

Page body — add two sections as content blocks:
## Problem
[2-4 sentences: what was wrong or what was needed. Include root cause if it's a bug.]
## Solution
[2-4 sentences: what was done. Mention key files or architectural decisions if relevant.]

Write in English. Be technical, concise, factual. Problem and Solution should be self-contained — readable months later without looking at code.

### Step 5: Output
Print exactly: DevLog created: [Name] ([Type]) — [Summary first sentence]
PROMPT_EOF
)

# Spawn background Claude process
claude -p "$PROMPT" \
  --model haiku \
  --permission-mode dontAsk \
  --allowedTools "mcp__notion__*" "Bash(git *)" \
  --no-session-persistence \
  --max-budget-usd 0.05 \
  > /dev/null 2>&1 &

exit 0
