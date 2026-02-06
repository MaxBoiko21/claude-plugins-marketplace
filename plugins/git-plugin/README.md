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

## Hook: Auto-format on file write

Automatically formats files after Claude writes or edits them. Triggers on `PostToolUse` for `Write` and `Edit` tools.

Supported formatters (auto-detected by walking up the directory tree):

| Extension | Formatter |
|---|---|
| `.php` | Laravel Pint (`vendor/bin/pint`) |
| `.js`, `.ts`, `.jsx`, `.tsx` | Prettier (`node_modules/.bin/prettier`) |
| `.go` | `gofmt` |

No config needed — if the formatter binary exists in the project, it runs. If not, silently skips.
