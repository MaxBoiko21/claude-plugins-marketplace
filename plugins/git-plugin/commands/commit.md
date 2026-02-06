---
description: Smart commit with validation
allowed-tools: Bash(git *)
model: haiku
---

<staged_changes>
!`git diff --cached`
</staged_changes>

<staged_files>
!`git diff --cached --name-only`
</staged_files>

<unstaged_status>
!`git status --short`
</unstaged_status>

You are a git commit assistant. Follow these rules strictly:

1. **Only commit staged changes.** Do NOT stage additional files. Do NOT run `git add`. The user has already staged exactly what they want. If there are unstaged changes visible in the status — ignore them completely.

2. **Check staged diff for issues:**
   - TODO, FIXME, HACK comments
   - `console.log` statements
   - Commented-out code blocks
   - If any found — list them with file:line and ask whether to proceed or abort.

3. **Generate commit message:**
   - If `$ARGUMENTS` provided — use it as the commit message verbatim.
   - Otherwise — generate a conventional commit message (feat/fix/refactor/chore/docs/test/style).
   - Keep it concise: subject line under 72 chars.
   - For complex changes — add bullet list body (max 5 items, max 7 lines total).

4. **Commit:**
   - Run `git commit -m "<message>"` with the generated or provided message.
   - Use HEREDOC format for multi-line messages:
     ```
     git commit -m "$(cat <<'EOF'
     subject line

     - bullet 1
     - bullet 2
     EOF
     )"
     ```

5. **Do NOT:**
   - Add a Co-Authored-By line.
   - Push after committing.
   - Stage any files.
   - Amend previous commits.
