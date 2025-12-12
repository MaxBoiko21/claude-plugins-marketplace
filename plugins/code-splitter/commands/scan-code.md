---
name: scan-code
description: Scan entire codebase for files that need refactoring
allowed-tools:
  - Glob
  - Grep
  - Read
  - Task
---

# Scan Codebase for Refactoring Candidates

Analyze the entire project to identify files needing refactoring based on:
- **Size**: Files exceeding line count thresholds
- **Complexity**: Methods/functions exceeding function count or cyclomatic complexity
- **Patterns**: Files not following action pattern conventions

## How It Works

1. **Scan the project**: Use Glob to identify all relevant code files
2. **Analyze each file**: Check size, method/function count, and patterns
3. **Generate report**: Present findings in interactive format with metrics
4. **Present candidates**: User can select which files to refactor with `/split-code`

## Instructions for Claude

Read project configuration from `.claude/code-splitter.local.md` if it exists (use Read tool).

Default thresholds (can be overridden in project config):
- **Size threshold**: 300 lines of code
- **Method/function threshold**: 10 methods/functions per file
- **Frameworks to detect**: Laravel, Symfony, React, Vue, Node.js

### Step 1: Detect Project Type

Use package.json, composer.json, and file structure to determine:
- Is this a Laravel/Symfony project? (check composer.json, app/ directory)
- Is this a React/Vue project? (check package.json, src/ directory)
- Is this a Node.js backend? (check package.json structure)
- Is this a mixed project? (multiple frameworks)

### Step 2: Identify Files to Scan

Based on project type, identify relevant file patterns:

**Laravel/Symfony:**
- Controllers: `app/**/*Controller.php`, `src/**/Controller/`
- Services: `app/**/Service.php`, `src/**/Service/`
- Models: `app/**/*.php` excluding Controllers, Actions
- Any file >300 lines in app/ or src/

**React/Vue:**
- Components: `src/components/**/*.{jsx,tsx,vue}`
- Sections: `src/sections/**/*.{jsx,tsx,vue}`
- Pages: `src/pages/**/*.{jsx,tsx,vue}`
- Hooks/Composables: `src/hooks/**/*.ts`, `src/composables/**/*.ts`

**Node.js:**
- Services: `src/services/**/*.ts`
- Controllers/Handlers: `src/routes/**/*.ts`, `src/handlers/**/*.ts`
- Any file >300 lines in src/

### Step 3: Analyze Each File

For each file:

1. **Count lines**: Total lines of code (excluding comments/blanks for accuracy)
2. **Count methods/functions**:
   - PHP: Count `public function`, `private function`, `protected function`
   - JS/TS: Count `function`, `async function`, `const x = () => {}`
   - Vue/React: Count `function`, exports, methods
3. **Assess pattern violations**:
   - Controllers with business logic (>30 lines of non-routing logic)
   - Large components without child components
   - Services doing multiple unrelated things
   - Files not following action pattern conventions

4. **Calculate refactoring score**:
   - Size violation: lines > 300 → add 1 point
   - Complexity violation: methods > 10 → add 1 point
   - Pattern violation: detected → add 1 point
   - Score > 0 = refactoring candidate

### Step 4: Generate Interactive Report

Present results as an interactive selection menu:

```
📊 Code Splitter Scan Report
=============================

Project Type: Laravel
Files Analyzed: 42
Candidates Found: 7

Refactoring Candidates:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

□ app/Http/Controllers/UserController.php
  Lines: 425 | Methods: 15 | Score: 2/3
  Issues: Size violation (125 lines over), complexity violation (5 extra methods)

□ app/Services/OrderService.php
  Lines: 380 | Methods: 18 | Score: 2/3
  Issues: Too many methods, mixed concerns (creation, payment, shipping)

□ app/Models/User.php
  Lines: 220 | Methods: 12 | Score: 1/3
  Issues: Complexity violation (2 extra methods)

✓ All other files are within thresholds

Recommended Action:
Use `/split-code <file-path>` on any candidate above to refactor it.
```

### Step 5: Interactive Selection (Optional)

If user wants, present a checkbox interface to select multiple candidates:

```
Select files to analyze further:

[✓] app/Http/Controllers/UserController.php
[ ] app/Services/OrderService.php
[ ] app/Models/User.php

Press to analyze selected files
```

## Output Format

Present as:
1. **Summary**: Total files analyzed, candidates found
2. **Detailed list**: Each candidate with metrics
3. **Recommendations**: Which files to prioritize
4. **Next steps**: Tell user to run `/split-code <file-path>` to refactor

## Error Handling

- If project has no code files: "No code files found. Verify project structure."
- If config file is malformed: Use default thresholds with warning
- If file is binary: Skip (don't try to read)

## Tips

- Sort candidates by refactoring score (highest first)
- Group by file type for easier processing
- Show framework-specific violation info (e.g., "Controller with business logic" for Laravel)
- Only show files that are actually refactoring candidates (have violations)

## Example Output Formats

**Laravel Project:**
```
File: app/Http/Controllers/UserController.php
Type: Controller
Lines: 425 (threshold: 300, 125 over)
Methods: 15 (threshold: 10, 5 over)
Violations:
  • Size: 425 lines exceeds 300 line threshold
  • Complexity: 15 methods exceeds 10 method threshold
  • Pattern: Heavy business logic should be in Action classes
Score: 3/3 - High Priority
```

**React Project:**
```
File: src/components/Dashboard.tsx
Type: Component
Lines: 380 (threshold: 300, 80 over)
Methods: 8 hooks + embedded logic
Violations:
  • Size: 380 lines exceeds 300 line threshold
  • Logic: Data fetching, form state, and rendering mixed
  • Pattern: Should split into sub-components and custom hooks
Score: 2/3 - Medium Priority
```

## Configuration

Read `.claude/code-splitter.local.md` for overrides:
- `line_threshold`: Override 300 line default
- `method_threshold`: Override 10 method default
- Language-specific paths to scan
