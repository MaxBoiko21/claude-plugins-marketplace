# Code Splitter Plugin

Intelligently scan and refactor large code files into smaller, maintainable action-pattern based components following language and framework conventions.

## Features

- **Codebase Scanning**: Automatically identify files that need refactoring based on size, complexity, and pattern conventions
- **File Splitting**: Refactor specific files into smaller, focused action/component files
- **Multi-Language Support**: Works with Laravel, Symfony, React, Vue, and Node.js projects
- **Action Pattern Enforcement**: Generates code following action pattern conventions (app/Actions for Laravel, custom patterns for other frameworks)
- **Smart Detection**: Auto-detects project type from dependencies (composer.json, package.json)
- **Project Configuration**: Customize thresholds and conventions per project using `.claude/code-splitter.local.md`
- **Factory/Seeder Support**: Automatically generates Laravel factories and seeders when refactoring models
- **Import Management**: Updates imports and references automatically after refactoring
- **Validation**: Validates generated code and suggests improvements

## Installation

```bash
# Plugin will be available at ~/.claude-plugins/code-splitter/
# Enable it in Claude Code settings or use: cc --plugin-dir ~/.claude-plugins/code-splitter/
```

## Usage

### Scan Entire Codebase

```
/scan-code
```

Analyzes your entire codebase and identifies files that need refactoring:
- Files exceeding size thresholds (default: >300 lines)
- Files with too many methods/functions (default: >10)
- Files violating action pattern conventions
- Shows interactive list of candidates with metrics
- You can select which files to refactor

### Split a Specific File

```
/split-code <file-path>
```

Refactors a specific file into smaller, focused components:
- Analyzes the file and proposes a refactoring plan
- Shows which methods/sections will be extracted
- You can manually select which extractions to perform
- Creates new action/component files following conventions
- Updates imports and references automatically
- Validates syntax and suggests improvements

## Project Configuration

Create `.claude/code-splitter.local.md` in your project root to customize behavior:

```yaml
---
# Laravel Settings
laravel_actions_path: app/Actions
laravel_generate_factories: true
laravel_generate_seeders: true

# React/Vue Settings
react_components_path: src/components
vue_components_path: src/components

# Node.js Settings
node_services_path: src/services
node_utils_path: src/utils

# Refactoring Thresholds
line_threshold: 300
method_threshold: 10
cyclomatic_complexity_threshold: 10

# Language-Specific Overrides
php_action_namespace: "App\\Actions"
js_module_extension: ".ts"
---

# Add any additional notes or conventions
```

All fields are optional. Plugin uses sensible defaults and auto-detects project type.

## How It Works

1. **Scanning**: Analyzes codebase structure, file sizes, complexity metrics, and pattern violations
2. **Detection**: Identifies refactoring candidates based on configurable thresholds
3. **Planning**: Creates a detailed refactoring plan showing which code will be extracted
4. **Approval**: Shows plan to user for manual selection and approval
5. **Execution**:
   - Creates new action/component files
   - Updates all imports and references
   - Validates generated code
   - Suggests quality improvements

## Supported Patterns

### Laravel
- Controllers → Action classes in `app/Actions/`
- Models → Traits and related actions
- Services → Modular service classes
- Factories and Seeders auto-generation

### React / Vue
- Large components → Smaller focused components
- Complex logic → Custom hooks / composables
- Props management → Component composition

### Node.js
- Large service files → Focused service modules
- Complex logic → Utility modules
- Route handlers → Separate handler functions

## Settings & Conventions

The plugin respects your project's existing conventions:
- **Laravel**: Follows action pattern from your coding standards
- **React**: Uses your component folder structure
- **Node.js**: Respects your service organization
- **General**: All thresholds and paths are configurable

## Tips

- Use `/scan-code` first to identify candidates across your entire codebase
- Run `/split-code` on individual files for precise control
- Configure `.claude/code-splitter.local.md` once per project for consistent refactoring
- The agent validates all generated code and won't create invalid files

## Skills Included

- **Code Refactoring Patterns**: Learn refactoring principles and best practices
- **Language-Specific Action Patterns**: Understand framework-specific conventions for your project type

## Feedback

Report issues or suggest improvements at the project repository.
