# Testing Checklist for Code Splitter Plugin

This document provides a step-by-step testing checklist to verify that the code-splitter plugin is working correctly in Claude Code.

## Installation & Loading

- [ ] Plugin directory exists at `~/.claude-plugins/code-splitter/`
- [ ] Enable plugin in Claude Code settings or run: `cc --plugin-dir ~/.claude-plugins/code-splitter/`
- [ ] Plugin loads without errors
- [ ] No conflicts with other plugins

## Command Testing

### `/scan-code` Command

1. **Test in a Laravel Project:**
   - [ ] Navigate to a Laravel project directory
   - [ ] Run `/scan-code`
   - [ ] Verify it analyzes files and identifies large controllers/services
   - [ ] Output shows file metrics (lines, methods) for candidates
   - [ ] Can see which files violate size/complexity thresholds

2. **Test in a React Project:**
   - [ ] Navigate to a React project directory
   - [ ] Run `/scan-code`
   - [ ] Identifies large components correctly
   - [ ] Shows component metrics
   - [ ] Can see which components have mixed concerns

3. **Test in a Node.js Project:**
   - [ ] Navigate to a Node.js project directory
   - [ ] Run `/scan-code`
   - [ ] Identifies service files exceeding thresholds
   - [ ] Shows proper metrics for Node services

### `/split-code <file-path>` Command

1. **Test with Laravel Controller:**
   - [ ] Run `/split-code app/Http/Controllers/SomeController.php`
   - [ ] Agent analyzes the controller
   - [ ] Shows refactoring plan with proposed Action classes
   - [ ] User can approve or adjust plan
   - [ ] New Action files are created in `app/Actions/`
   - [ ] Original controller is updated to use Actions
   - [ ] Imports are correctly added

2. **Test with React Component:**
   - [ ] Run `/split-code src/components/LargeComponent.tsx`
   - [ ] Agent analyzes the component
   - [ ] Proposes breaking into smaller components/hooks
   - [ ] Shows where sub-components will be created
   - [ ] Creates new component files in `src/components/`
   - [ ] Creates custom hooks in `src/hooks/` if needed
   - [ ] Updates original component to use new pieces

3. **Test with Node.js Service:**
   - [ ] Run `/split-code src/services/UserService.ts`
   - [ ] Agent analyzes the service
   - [ ] Proposes splitting into focused services
   - [ ] Creates new service files in `src/services/`
   - [ ] Updates imports in original file
   - [ ] Maintains TypeScript typing

## Skills Testing

### Code Refactoring Patterns Skill

- [ ] Triggered when asking "How should I refactor this code?"
- [ ] Triggered when asking "How can I split this file?"
- [ ] Provides refactoring principles and best practices
- [ ] References extraction patterns in details
- [ ] Helps understand SRP and extraction boundaries

### Action Pattern Conventions Skill

- [ ] Triggered when asking "How do I structure Laravel actions?"
- [ ] Triggered when asking "What's the React component pattern?"
- [ ] Provides framework-specific conventions
- [ ] Shows Laravel action examples
- [ ] Shows React hook examples
- [ ] Shows Node.js service examples
- [ ] Auto-detects project type

## Agent Testing

### Code Splitter Agent

1. **Autonomous Operation:**
   - [ ] Agent runs automatically when commands are executed
   - [ ] No manual prompting needed for basic operations
   - [ ] Agent makes intelligent decisions about extractions

2. **Analysis Capabilities:**
   - [ ] Correctly analyzes file size and complexity
   - [ ] Identifies multiple responsibilities
   - [ ] Recognizes extraction boundaries
   - [ ] Respects project conventions

3. **Plan Generation:**
   - [ ] Shows clear, structured refactoring plans
   - [ ] Explains why each extraction is proposed
   - [ ] Shows target file paths following conventions
   - [ ] Lists dependencies for extracted code

4. **Execution:**
   - [ ] Creates new files correctly
   - [ ] Updates original files properly
   - [ ] Adds necessary imports
   - [ ] Validates syntax after changes

5. **Validation:**
   - [ ] Checks that generated code is syntactically correct
   - [ ] Suggests improvements when appropriate
   - [ ] Summarizes what was done
   - [ ] Prevents breaking changes

## Settings Testing

1. **Default Behavior:**
   - [ ] Plugin works without `.claude/code-splitter.local.md`
   - [ ] Uses sensible defaults (300 lines, 10 methods)
   - [ ] Auto-detects project type correctly

2. **With Project Config:**
   - [ ] Create `.claude/code-splitter.local.md` in project root
   - [ ] Set custom thresholds and paths
   - [ ] Plugin respects configuration
   - [ ] Custom paths are used for new files
   - [ ] Custom thresholds are applied in scanning

## Error Handling

- [ ] Handles missing files gracefully ("File not found")
- [ ] Handles unrecognized file types ("Cannot refactor this type")
- [ ] Handles permission errors appropriately
- [ ] Handles syntax errors in files being analyzed
- [ ] Provides helpful error messages

## Output Quality

- [ ] Commands output is well-formatted and readable
- [ ] Agent output is clear and well-structured
- [ ] File paths are shown correctly
- [ ] Code examples are properly formatted
- [ ] Suggestions are helpful and actionable

## Documentation

- [ ] README.md is complete and helpful
- [ ] Installation instructions work
- [ ] Usage examples are clear
- [ ] Configuration examples are provided
- [ ] All features are documented

## Integration

- [ ] Plugin doesn't interfere with other Claude Code features
- [ ] Can use other commands while plugin is active
- [ ] Works with existing Claude Code tools (Read, Write, Edit, etc.)
- [ ] Respects user's project structure

## Framework-Specific Testing

### Laravel
- [ ] Detects Laravel projects correctly
- [ ] Creates actions in `app/Actions/` directory
- [ ] Follows Laravel action pattern
- [ ] Generates factories if project uses them
- [ ] Handles Form Requests correctly

### React
- [ ] Detects React projects correctly
- [ ] Creates components in `src/components/`
- [ ] Creates hooks in `src/hooks/`
- [ ] Follows React best practices
- [ ] Proper TypeScript support

### Vue
- [ ] Detects Vue projects correctly
- [ ] Creates components in `src/components/`
- [ ] Creates composables in `src/composables/`
- [ ] Follows Vue 3 patterns
- [ ] Proper TypeScript support

### Node.js
- [ ] Detects Node.js projects correctly
- [ ] Creates services in `src/services/`
- [ ] Creates actions in `src/actions/` for complex workflows
- [ ] Proper TypeScript typing
- [ ] Follows service pattern

## Performance

- [ ] Scanning large codebases completes in reasonable time
- [ ] No timeouts on file analysis
- [ ] Refactoring execution is responsive
- [ ] No performance degradation with plugin enabled

## Overall Quality

- [ ] Plugin is production-ready
- [ ] All components work together smoothly
- [ ] Documentation is complete
- [ ] No obvious bugs or issues
- [ ] User experience is smooth and helpful

---

## Test Results Summary

**Date Tested:** _________________
**Tester:** _________________
**Plugin Version:** 0.1.0

**Overall Status:**
- [ ] PASS - All tests passed, plugin is ready
- [ ] PASS with Notes - Minor issues noted but plugin is usable
- [ ] FAIL - Critical issues need fixing

**Issues Found:**
```
[List any issues discovered during testing]
```

**Notes:**
```
[Any additional observations or feedback]
```

---

## Post-Testing Actions

- [ ] Fix any critical issues
- [ ] Update documentation if needed
- [ ] Iterate based on test results
- [ ] Ready for distribution/sharing

---

## Usage Quick Start

Once plugin is loaded and tested, users can:

1. **Scan entire codebase:** `/scan-code`
2. **Refactor specific file:** `/split-code path/to/file.php`
3. **Learn refactoring patterns:** Ask "How should I refactor this?"
4. **Understand conventions:** Ask "What's the Laravel action pattern?"
5. **Configure project:** Create `.claude/code-splitter.local.md`
