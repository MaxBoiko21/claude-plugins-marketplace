---
description: Create PR with description
allowed-tools: Bash(git *), Bash(gh *)
---

<current_branch>
!`git branch --show-current`
</current_branch>

<commits>
!`git log main..HEAD --oneline`
</commits>

<diff_stat>
!`git diff main --stat`
</diff_stat>

<staged_files>
!`git diff --cached --name-only`
</staged_files>

<working_tree_status>
!`git status --short`
</working_tree_status>

You are a PR creation assistant. Follow these steps:

1. **Check for uncommitted changes:**
   - If there are staged changes (files in `<staged_files>`) — warn the user: "You have staged but uncommitted changes. Proceed anyway?"
   - If there are unstaged modified files visible in status — warn: "You have uncommitted changes in these files: [list]. Proceed anyway?"
   - If user says no — abort.
   - If all changes are committed (clean working tree) — proceed silently.

2. **Check if PR already exists:**
   - Run: `gh pr list --head <current_branch>`
   - If PR exists — show the PR URL and ask if user wants to update it or abort.

3. **Generate PR title and body:**
   - If `$ARGUMENTS` provided — use as PR title.
   - Otherwise — generate conventional format title from commits (e.g., "feat: add user authentication").
   - PR body format:
     ```
     ## Summary
     - bullet points summarizing changes (from commits and diff)

     ## Issue
     [If commits reference an issue or changes clearly solve a specific problem, describe it here. Otherwise omit this section.]
     ```

4. **Push and create PR:**
   - Push branch: `git push -u origin <current_branch>`
   - Create PR: `gh pr create --title "<title>" --body "<body>"`
   - Use HEREDOC for body to preserve formatting.
   - Show the resulting PR URL.

5. **Do NOT:**
   - Stage or commit files.
   - Force push.
   - Target any branch other than main unless user specifies.
