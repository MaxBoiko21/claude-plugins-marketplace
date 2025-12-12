# Quick Start Guide - Code Splitter Plugin

## 1. Enable the Plugin

The plugin is ready at: `~/.claude-plugins/code-splitter/`

In Claude Code, enable it with:
```bash
cc --plugin-dir ~/.claude-plugins/code-splitter/
```

Or add to your `.claude/settings.json`:
```json
{
  "plugins": {
    "code-splitter": {
      "enabled": true,
      "directory": "~/.claude-plugins/code-splitter"
    }
  }
}
```

## 2. Your First Scan

Navigate to any of your projects and run:
```
/scan-code
```

The agent will:
- Detect your project type (Laravel, React, Vue, Node.js, etc.)
- Analyze all code files
- Identify files exceeding size/complexity thresholds
- Show you a report with candidates for refactoring

**Example Output:**
```
📊 Code Splitter Scan Report
============================

Project Type: Laravel
Files Analyzed: 42
Candidates Found: 5

Refactoring Candidates:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ app/Http/Controllers/UserController.php
  Lines: 425 | Methods: 15 | Issues: Size + Complexity

✓ app/Services/OrderService.php
  Lines: 380 | Methods: 18 | Issues: Multiple concerns

[... more candidates ...]
```

## 3. Refactor a Specific File

Once you've identified a file to refactor, use:
```
/split-code app/Http/Controllers/UserController.php
```

The agent will:
1. **Analyze** the file structure
2. **Propose** a refactoring plan
3. **Ask for approval** before making changes
4. **Execute** the refactoring
5. **Validate** the generated code

**Interactive Approval:**
```
Refactoring Plan: UserController.php
====================================

Current Issues:
  • Size: 425 lines (125 over threshold)
  • Complexity: 15 methods (5 over threshold)
  • Mixed concerns: routing, validation, business logic

Proposed Extractions:
1. CreateUserAction (app/Actions/Users/)
2. UpdateUserAction (app/Actions/Users/)
3. DeleteUserAction (app/Actions/Users/)

Continue with this plan? [yes/no/adjust]
```

## 4. Learn Best Practices

Ask the plugin for guidance:
```
/chat: "How should I refactor this code?"
```

The **Code Refactoring Patterns** skill will trigger and explain:
- Single Responsibility Principle
- Extraction boundaries
- Complexity metrics
- Red flags to watch for

Or ask about your framework:
```
/chat: "How do I structure Laravel actions?"
```

The **Action Pattern Conventions** skill will explain:
- Laravel action pattern with examples
- React component & hook patterns
- Vue composable patterns
- Node.js service patterns

## 5. Configure Your Project (Optional)

Create `.claude/code-splitter.local.md` in your project root:

```yaml
---
# Customize for your project

# Laravel
laravel_actions_path: app/Actions
laravel_generate_factories: true

# React
react_components_path: src/components
react_hooks_path: src/hooks

# Node.js
node_services_path: src/services

# Thresholds
line_threshold: 300
method_threshold: 10
---
```

The plugin will respect these settings when refactoring.

## 6. Common Use Cases

### Scenario 1: Large Controller (Laravel)
```
/split-code app/Http/Controllers/UserController.php
```
Creates Action classes in `app/Actions/Users/` following Laravel conventions.

### Scenario 2: Complex Component (React)
```
/split-code src/components/Dashboard.tsx
```
Splits into smaller components and extracts hooks.

### Scenario 3: Overloaded Service (Node.js)
```
/split-code src/services/UserService.ts
```
Breaks into focused services by responsibility.

## 7. Tips for Success

✅ **Do:**
- Start with `/scan-code` to understand refactoring opportunities
- Review proposed plans carefully before approval
- Run tests after refactoring to verify functionality
- Configure `.claude/code-splitter.local.md` for consistency
- Use the skills to understand refactoring principles

❌ **Don't:**
- Refactor too many things at once
- Skip reviewing the refactoring plan
- Forget to verify imports after refactoring
- Ignore syntax validation errors
- Force extractions that don't make sense

## 8. Troubleshooting

**Command not working:**
1. Make sure you're in your project directory
2. Restart Claude Code
3. Check plugin is enabled with `/help`

**Agent not analyzing correctly:**
1. Verify file exists and is readable
2. Check file is a supported language (.php, .tsx, .ts, .vue, etc.)
3. Try with a simpler file first

**Settings not being applied:**
1. Create `.claude/code-splitter.local.md` in project root
2. Use valid YAML syntax
3. Include `---` before and after the settings

## 9. Next Steps

1. **For immediate use:** Run `/scan-code` in your project
2. **To learn more:** See `README.md` for full documentation
3. **To test:** Follow the checklist in `TESTING.md`
4. **For reference:** Check `PLUGIN_SUMMARY.md` for technical details

## 10. Key Commands Reference

| Command | Use Case |
|---------|----------|
| `/scan-code` | Find refactoring candidates in entire codebase |
| `/split-code <path>` | Refactor specific file |
| *Ask about refactoring* | Learn best practices (triggers skill) |
| *Ask about framework patterns* | Understand conventions (triggers skill) |

---

## Example Session

```
# 1. Scan your project
/scan-code

# Output shows: app/Http/Controllers/UserController.php needs refactoring

# 2. Ask for guidance
/chat: "How should I refactor a large controller?"

# Output: Code Refactoring Patterns skill explains principles

# 3. Refactor the file
/split-code app/Http/Controllers/UserController.php

# Output: Shows plan, waits for approval

# 4. Review results
# New files created: app/Actions/Users/{CreateUserAction,UpdateUserAction,DeleteUserAction}.php
# Modified: app/Http/Controllers/UserController.php (now just routing)

# 5. Verify
# Check imports, run tests, done!
```

---

**You're ready to start! Run `/scan-code` in your project to see what needs refactoring.**
