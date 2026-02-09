# git-plugin

Personal git workflow commands for Claude Code: smart commit, PR creation, and code review.

## Installation

```bash
claude plugin add /path/to/git-plugin
```

## Commands

### `/commit` — Smart commit with validation

Commits staged changes with auto-generated conventional commit messages.

```bash
/commit                    # auto-generate message from staged diff
/commit fix: typo in auth  # use provided message verbatim
```

What it does:
- Scans staged diff for issues (TODO/FIXME, `console.log`, commented-out code) and warns before committing
- Generates conventional commit messages (`feat`, `fix`, `refactor`, etc.)
- Multi-line body for complex changes (bullet list, max 5 items)

What it does NOT do:
- Stage files — only commits what you've already staged
- Push, amend, or add Co-Authored-By

Uses `haiku` model to keep it fast and cheap.

### `/pr` — Create PR with description

Pushes the current branch and creates a GitHub PR via `gh`.

```bash
/pr                        # auto-generate title from commits
/pr feat: user dashboard   # use provided title
```

What it does:
- Warns about uncommitted/staged changes before proceeding
- Checks if a PR already exists for the branch
- Generates PR body with summary bullets from commits and diff
- Pushes branch and creates PR targeting `main`

Requires: [GitHub CLI](https://cli.github.com/) (`gh`) installed and authenticated.

### `/review` — Review current changes

Reviews uncommitted changes (staged + unstaged) for real issues.

```bash
/review                # full review
/review security       # focus on security
/review src/auth.ts    # focus on specific file
```

Checks for:
- **Security** — injection, exposed secrets, path traversal
- **Performance** — N+1 queries, unnecessary re-renders, blocking calls
- **Logic errors** — off-by-one, null access, race conditions, missing error handling

Findings grouped by severity: Critical > Warning > Info. No nitpicking — skips if nothing found.

Uses `sonnet` model for deeper analysis.

### `/devlog` — Create Notion DevLog entry

Creates a DevLog entry in Notion for the last commit. Useful for testing or ad-hoc logging.

```bash
/devlog                          # log last commit
/devlog added retry logic to API # add extra context to summary
```

What it does:
- Reads last commit info (hash, message, date, diff stats)
- Classifies type from conventional commit prefix (feat→Feature, fix→Bug, etc.)
- Finds or creates project in Notion Projects DB by repo name
- Queries last 100 DevLog entries for related logs and auto-links them
- Creates DevLog entry with summary, time estimate, and commit URL

Requires: Notion MCP integration configured (see setup below).

Uses `haiku` model to keep it fast and cheap.

## Hooks

### Auto-format on file write

Automatically formats files after Claude writes or edits them. Triggers on `PostToolUse` for `Write` and `Edit` tools.

Supported formatters (auto-detected by walking up the directory tree):

| Extension | Formatter |
|---|---|
| `.php` | Laravel Pint (`vendor/bin/pint`) |
| `.js`, `.ts`, `.jsx`, `.tsx` | Prettier (`node_modules/.bin/prettier`) |
| `.go` | `gofmt` |

No config needed — if the formatter binary exists in the project, it runs. If not, silently skips.

### Auto DevLog on commit

Automatically creates a Notion DevLog entry after every successful `git commit`. Triggers on `PostToolUse` for `Bash` tool.

- Detects `git commit` commands (skips `--amend`)
- Verifies commit succeeded (checks for `[branch hash]` output)
- Spawns a background Claude process with Notion MCP access
- Non-blocking — hook exits immediately, DevLog creation happens in background

Same logic as `/devlog`: classifies type, finds/creates project, links related logs, creates entry.

Requires: Notion MCP integration configured (see setup below).

## Notion MCP Setup

The `/devlog` command and auto-devlog hook require Notion MCP integration:

1. Install a Notion MCP plugin or configure Notion MCP manually
2. The MCP endpoint is `https://mcp.notion.com/mcp`
3. Auth via OAuth — run `/mcp` and follow the Notion auth flow
4. Grant access to your Projects and DevLog databases in Notion integration settings
