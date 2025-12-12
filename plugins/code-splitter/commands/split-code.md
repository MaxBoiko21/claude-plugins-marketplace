---
name: refactor
description: Refactor a specific file by splitting it into smaller action/component files
argument-hint: <file-path>
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Task
---

# Refactor and Split Specific File

Analyze a specific file and execute refactoring to split it into smaller, focused components following action pattern conventions.

## Parameters

- `file-path` (required): Full path to the file to refactor

## How It Works

1. **Analyze the file**: Read and understand its structure, responsibilities, and violations
2. **Propose refactoring plan**: Show which code will be extracted and where
3. **User approval**: User selects which extractions to perform
4. **Execute refactoring**: Create new files and update imports
5. **Validate**: Check syntax and suggest improvements

## Instructions for Claude

### Step 1: Read and Analyze the File

1. Use Read tool to load the specified file
2. Understand its current structure:
   - What is it doing? (business logic, data access, rendering, etc.)
   - How many methods/functions? What do they do?
   - How many lines?
   - Current violations (size, complexity, multiple concerns)
3. Determine the file type:
   - PHP file? (Laravel controller, service, model)
   - JavaScript/TypeScript? (Node service, React component, Vue component)
   - Identify the framework context

### Step 2: Load Project Configuration

1. Try to read `.claude/code-splitter.local.md` from project root
2. Extract project preferences:
   - Target action paths (laravel_actions_path, react_components_path, etc.)
   - Language-specific conventions
   - Naming preferences
3. If no config exists, use defaults for detected framework

### Step 3: Propose Refactoring Plan

Create a detailed plan showing:

**For each extraction:**
- What code is being extracted (which methods/functions/sections)
- Where it will be created (new file path following conventions)
- What dependencies it needs
- How it connects to remaining code

**Example Laravel plan:**
```
Refactoring Plan: app/Http/Controllers/UserController.php
═════════════════════════════════════════════════════════

Current Issues:
  • File size: 425 lines (125 lines over threshold)
  • Methods: 15 (5 methods over threshold)
  • Mixed concerns: routing, validation, business logic, email sending

Proposed Extractions:

1. Create User Action
   File: app/Actions/Users/CreateUserAction.php
   Extracts: store() method business logic
   Dependencies: User model, Mail service
   Connections: Controller calls this action

2. Update User Action
   File: app/Actions/Users/UpdateUserAction.php
   Extracts: update() method business logic
   Dependencies: User model
   Connections: Controller calls this action

3. Delete User Action
   File: app/Actions/Users/DeleteUserAction.php
   Extracts: destroy() method logic
   Dependencies: User model
   Connections: Controller calls this action

4. Send User Invitation
   File: app/Actions/Users/SendUserInvitationAction.php
   Extracts: sendInvitation() method
   Dependencies: Mail service
   Connections: Controller calls this action

Result:
  • Controller reduced to ~50 lines (routing only)
  • Each action has single responsibility
  • Code is testable and reusable
  • Following Laravel action pattern
```

**For React/Vue, show component breakdown:**
```
Refactoring Plan: src/components/UserDashboard.tsx
═════════════════════════════════════════════════

Current Issues:
  • Component size: 380 lines (80 over threshold)
  • Mixed concerns: data fetching, form state, rendering
  • No child components

Proposed Extractions:

1. useUserData Hook
   File: src/hooks/useUserData.ts
   Extracts: User fetching logic
   Dependencies: React Query/SWR
   Connections: UserDashboard imports and uses it

2. UserProfile Component
   File: src/sections/UserProfile.tsx
   Extracts: Profile rendering section
   Dependencies: User type
   Connections: Receives user prop from UserDashboard

3. UserForm Component
   File: src/sections/UserForm.tsx
   Extracts: Form rendering and submission
   Dependencies: useUserForm hook
   Connections: Receives user prop, calls onSuccess

4. UserActivity Component
   File: src/sections/UserActivity.tsx
   Extracts: Activity list rendering
   Dependencies: useUserActivities hook
   Connections: Receives userId prop

Result:
  • Dashboard component: ~50 lines of layout
  • Each section has single responsibility
  • Reusable hooks and components
  • Better code organization
```

### Step 4: Present Plan to User

Format as structured proposal:
- Show current issues clearly
- List each extraction with file path and purpose
- Show resulting file structure
- Ask user: "Should I proceed with this plan?" or "Would you like to adjust?"

### Step 5: User Selection

Allow user to:
- Accept the entire plan
- Remove specific extractions ("Don't extract #3")
- Add notes or adjustments
- Proceed to execution

### Step 6: Execute Refactoring

For **each extraction the user approved**:

1. **Create new file**:
   - Use Write tool to create new file at proposed location
   - Copy extracted code into new file
   - Add necessary imports/dependencies
   - Add proper file structure (class, function, component, etc.)

2. **Update original file**:
   - Use Edit tool to replace extracted code with function/class call
   - Add imports for new files
   - Keep only the router/handler/layout logic

3. **Validate syntax**:
   - Check if file is valid (no syntax errors)
   - Verify imports are correct
   - Ensure function signatures match

### Step 7: Generate Summary & Suggestions

Show user what was created:

```
✅ Refactoring Complete!
═════════════════════════════════════════

Files Created:
  ✓ app/Actions/Users/CreateUserAction.php (45 lines)
  ✓ app/Actions/Users/UpdateUserAction.php (38 lines)
  ✓ app/Actions/Users/DeleteUserAction.php (25 lines)

Files Modified:
  ✓ app/Http/Controllers/UserController.php
    Reduced from 425 → 65 lines

Result:
  • Original controller now focused on routing only
  • Each action has clear single responsibility
  • Code is testable and reusable from multiple places
  • Following Laravel action pattern

Next Steps:
  1. Run tests to verify functionality
  2. Check imports if using IDE
  3. Consider creating test files for new actions
```

### Step 8: Validation & Suggestions

After refactoring, suggest improvements:

```
💡 Suggestions for Further Improvement:

1. Create Factory for CreateUserAction tests
   Path: database/factories/UserFactory.php

2. Consider extracting validation to Form Request
   Path: app/Http/Requests/StoreUserRequest.php

3. Add event dispatching for user creation
   Would allow notifications without tight coupling
```

## Language-Specific Handling

### Laravel/Symfony

- Extract to Action classes in `app/Actions/` (Laravel) or `src/Service/` (Symfony)
- Each action: `handle()` or `execute()` method
- Dependency injection via constructor
- Use Form Requests for validation
- Auto-generate factories if project uses them

### React

- Extract to custom hooks (state/logic) in `src/hooks/`
- Extract to components (rendering) in `src/components/` or `src/sections/`
- Use TypeScript interfaces for props
- Custom hooks start with `use` prefix
- Memoize if needed

### Vue

- Extract to composables (logic) in `src/composables/`
- Extract to components (rendering) in `src/components/` or `src/views/`
- Use TypeScript interfaces
- Composables start with `use` prefix
- Return reactive objects

### Node.js

- Extract to Service classes in `src/services/`
- Extract to Action classes for complex multi-step operations
- Dependency injection via constructor
- Use TypeScript for type safety

## File Handling

**Before Creating Files:**
1. Check if target directory exists (using Glob)
2. Check if file already exists
3. If exists, ask user: "File exists, should I overwrite?"

**Import Updates:**
1. Auto-add necessary imports to modified files
2. Update references from old methods to new extracted classes/functions
3. Verify import paths are correct for the project structure

## Error Handling

- **Invalid file path**: "File not found. Check the path and try again."
- **Unrecognized file type**: "Cannot refactor this file type. Supported: .php, .tsx, .ts, .vue, .jsx"
- **Parse error**: "Could not parse file. Check for syntax errors first."
- **Permission denied**: "Cannot write to target directory. Check permissions."

## Tips for Quality Results

- Preserve comments and documentation
- Keep cohesive logic together
- Don't create too many tiny files (each should be ~30-100 lines)
- Group related actions together (all User actions in Users/ folder)
- Update tests if they exist
- Suggest adding test files for new actions/components

## Configuration

Read `.claude/code-splitter.local.md`:
- `laravel_actions_path`: Where to create Laravel actions
- `react_components_path`: Where to create React components
- `vue_composables_path`: Where to create Vue composables
- `node_services_path`: Where to create Node services
- Any language-specific conventions
