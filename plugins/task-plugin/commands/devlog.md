---
description: Create DevLog entry for last commit
allowed-tools: Bash(ws *), Bash(git *)
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

<repo_path>
!`git rev-parse --show-toplevel 2>/dev/null`
</repo_path>

<current_branch>
!`git branch --show-current 2>/dev/null`
</current_branch>

You are a DevLog assistant. Create a DevLog entry for the last commit via the `ws` CLI.

## Extra context from user
$ARGUMENTS

## Step 1: Parse commit data

From `<last_commit>`, split by `|` to get: commit hash, commit message, commit date.
From `<remote_url>`, extract `owner/repo` path (strip `https://github.com/` or `git@github.com:` prefix and `.git` suffix). Construct commit URL: `https://github.com/{owner}/{repo}/commit/{hash}`.
If remote URL is empty, skip commit URL.

## Step 2: Classify type from commit prefix

Map the conventional commit prefix:
- feat → feature
- fix → bug
- refactor → refactor
- hotfix → hotfix
- anything else → feature

## Step 3: Find or create project

Extract the repo name from `<repo_path>` (last path segment).

Search: `ws project search <repo_name>`

If NOT found, auto-create with sensible defaults (no blocking prompts):
```bash
ws project add "<repo_name>" --stack "unknown" --priority medium --pleasure medium
```

## Step 4: Generate entry content

From the diff context and user's `$ARGUMENTS`, generate:
- **Title:** Derive from commit message — strip the conventional prefix (feat:, fix:, etc.), capitalize first letter. Keep concise.
- **Summary:** 1-2 sentences, readable at a glance.
- **Problem:** 2-4 sentences — what was wrong or what was needed.
- **Solution:** 2-4 sentences — what was done. Mention key files or architectural decisions.
- **AI Estimate:** Honest estimate in hours (round to 0.25). Base on diff complexity.

## Step 5: Create entry

```bash
ws devlog add "<title>" \
  --project <repo_name> --type <type> --summary "<summary>" \
  --problem "<problem>" --solution "<solution>" \
  --ai_estimate <hours> --commit_url "<url>" \
  --branch "<current_branch>"
```

Skip `--commit_url` if no remote. Skip `--claude_session` (reserved for future use).

## Step 6: Output

Print: **DevLog created:** [Title] ([Type]) — [Summary first sentence]

### Writing guidelines
- English, technical, concise, factual. No fluff.
- Summary should be one line ideally.
- Problem and Solution should be self-contained — someone reading months later should understand without looking at code.
