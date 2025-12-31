# Roadmap

This document outlines potential improvements, new features, and code cleanup opportunities for the todo-app project.

---

## Feature Proposals

### [Priority: High] Add Due Dates to Todos
**Description:** Allow users to set optional due dates on todos with visual indicators for overdue items.
**Rationale:** Due dates are a fundamental feature of most todo applications. They enable users to prioritize and plan their work effectively.
**Affected Files:**
- `TodoApp/Models.lean` - Add `:todo/due-date` attribute
- `TodoApp/Helpers.lean` - Add date parsing/formatting helpers
- `TodoApp/Actions/Todos.lean` - Handle due date in create/edit actions
- `TodoApp/Views/Todos.lean` - Add date input and display overdue styling
- `public/styles.css` - Add overdue item styling
- `Tests/Main.lean` - Add due date tests
**Estimated Effort:** Medium
**Dependencies:** None (may benefit from integrating the `chronos` library for time handling)

### [Priority: High] Add Todo Reordering (Drag and Drop)
**Description:** Allow users to reorder their todos within the active and completed sections.
**Rationale:** Task prioritization through manual ordering is a core productivity feature. The homebase-app Kanban board demonstrates this pattern.
**Affected Files:**
- `TodoApp/Models.lean` - Add `:todo/position` attribute
- `TodoApp/Actions/Todos.lean` - Add `reorder` action
- `TodoApp/Views/Todos.lean` - Add sortable container markup
- `public/styles.css` - Add drag handle styling
- New file: `public/js/todos.js` - Drag and drop JavaScript
**Estimated Effort:** Medium
**Dependencies:** None

### [Priority: Medium] Add Todo Categories/Tags
**Description:** Allow users to categorize todos with tags (e.g., "work", "personal", "urgent").
**Rationale:** Tags enable filtering and organization of todos, especially useful as the list grows.
**Affected Files:**
- `TodoApp/Models.lean` - Add `:todo/tags` attribute (multi-valued)
- `TodoApp/Helpers.lean` - Add tag parsing utilities
- `TodoApp/Actions/Todos.lean` - Handle tags in create/edit, add filter action
- `TodoApp/Views/Todos.lean` - Display tags, add filter UI
- `public/styles.css` - Tag pill styling
**Estimated Effort:** Medium
**Dependencies:** None

### [Priority: Medium] Add Server-Sent Events for Real-Time Updates
**Description:** Implement SSE so that multiple browser tabs/devices stay synchronized.
**Rationale:** The homebase-app demonstrates this pattern effectively. It prevents stale data when users have multiple tabs open.
**Affected Files:**
- `TodoApp/Main.lean` - Add SSE endpoint registration
- `TodoApp/Actions/Todos.lean` - Publish events on create/update/delete
- `TodoApp/Views/Todos.lean` - Include JavaScript for SSE handling
- New file: `public/js/todos.js` - SSE event handling
**Estimated Effort:** Medium
**Dependencies:** None (Loom already supports SSE)

### [Priority: Medium] Add Todo Search
**Description:** Add a search box to filter todos by title text.
**Rationale:** As todo lists grow, search becomes essential for finding specific items quickly.
**Affected Files:**
- `TodoApp/Actions/Todos.lean` - Handle search query parameter
- `TodoApp/Views/Todos.lean` - Add search input field
- `TodoApp/Helpers.lean` - Add search filtering function
**Estimated Effort:** Small
**Dependencies:** None

### [Priority: Medium] Add "Complete All" and "Clear Completed" Buttons
**Description:** Bulk actions for marking all todos complete or clearing completed items.
**Rationale:** Standard todo app features that improve efficiency for power users.
**Affected Files:**
- `TodoApp/Actions/Todos.lean` - Add `completeAll` and `clearCompleted` actions
- `TodoApp/Views/Todos.lean` - Add buttons in the UI
- `TodoApp/Main.lean` - Register new routes
**Estimated Effort:** Small
**Dependencies:** None

### [Priority: Low] Add Todo Notes/Description
**Description:** Allow users to add longer notes or descriptions to todos.
**Rationale:** Some tasks benefit from additional context beyond a title.
**Affected Files:**
- `TodoApp/Models.lean` - Add `:todo/notes` attribute
- `TodoApp/Actions/Todos.lean` - Handle notes in create/edit
- `TodoApp/Views/Todos.lean` - Add notes textarea, show in detail view
**Estimated Effort:** Small
**Dependencies:** None

### [Priority: Low] Add Password Reset Flow
**Description:** Allow users to reset their password via email.
**Rationale:** Standard security feature for user accounts.
**Affected Files:**
- `TodoApp/Models.lean` - Add `:user/reset-token` and `:user/reset-expiry` attributes
- `TodoApp/Actions/Auth.lean` - Add password reset request and confirmation actions
- `TodoApp/Views/Auth.lean` - Add reset password forms
- `TodoApp/Main.lean` - Register new routes
**Estimated Effort:** Large (requires email integration)
**Dependencies:** Email sending capability (not currently in the workspace)

### [Priority: Low] Add User Profile Page
**Description:** Allow users to view and update their profile (name, email, password).
**Rationale:** Users should be able to manage their account settings.
**Affected Files:**
- `TodoApp/Actions/` - New file `Profile.lean`
- `TodoApp/Views/` - New file `Profile.lean`
- `TodoApp/Main.lean` - Register profile routes
**Estimated Effort:** Medium
**Dependencies:** None

---

## Code Improvements

### [Priority: High] Replace Demo Password Hashing with Production-Ready Solution
**Current State:** `TodoApp/Helpers.lean` uses a simple polynomial hash with an explicit comment "demo only - use bcrypt/argon2 in production".
**Proposed Change:** Implement or integrate a proper cryptographic password hashing algorithm (bcrypt, scrypt, or argon2).
**Benefits:** Security improvement - current implementation is vulnerable to rainbow table attacks and lacks salt.
**Affected Files:**
- `TodoApp/Helpers.lean` - Replace `polyHash` with secure hashing
- May require new FFI bindings for crypto library
**Estimated Effort:** Medium (requires FFI work)

### [Priority: High] Use Route Middleware for Authentication
**Current State:** Authentication is checked manually in each protected action with `requireUserId` or inline session checks. The comment in `Main.lean` says "Protected routes (auth check happens in actions)".
**Proposed Change:** Use Loom's `RouteMiddleware.guard` pattern as demonstrated in homebase-app's `Middleware.lean`.
**Benefits:** Cleaner code, centralized auth logic, impossible to forget auth checks on new routes.
**Affected Files:**
- `TodoApp/` - New file `Middleware.lean` with `authRequired` middleware
- `TodoApp/Main.lean` - Apply middleware to protected routes
- `TodoApp/Actions/Todos.lean` - Remove redundant auth checks
**Estimated Effort:** Small

### [Priority: Medium] Consolidate Action Patterns
**Current State:** `Actions/Home.lean` uses the raw `Action` type, while `Actions/Todos.lean` uses `ActionM`. `Actions/Auth.lean` uses `Action` with manual context threading.
**Proposed Change:** Standardize all actions to use `ActionM` monad for consistency.
**Benefits:** Consistent code style, easier to maintain, better use of Loom's monadic patterns.
**Affected Files:**
- `TodoApp/Actions/Home.lean` - Convert to ActionM
- `TodoApp/Actions/Auth.lean` - Convert to ActionM
**Estimated Effort:** Small

### [Priority: Medium] Add Input Validation
**Current State:** Basic validation exists (empty checks) but no email format validation, password strength requirements, or length limits.
**Proposed Change:** Add comprehensive input validation with descriptive error messages.
**Benefits:** Better UX, security improvement, prevents malformed data.
**Affected Files:**
- `TodoApp/Helpers.lean` - Add validation functions
- `TodoApp/Actions/Auth.lean` - Apply email/password validation
- `TodoApp/Actions/Todos.lean` - Apply title length validation
**Estimated Effort:** Small

### [Priority: Medium] Serve Static Files Properly
**Current State:** `public/styles.css` exists but there's no static file serving middleware. The layout references `/styles.css` via a raw string.
**Proposed Change:** Add Loom's static file middleware and proper asset serving.
**Benefits:** CSS and future JS files will be served correctly without manual configuration.
**Affected Files:**
- `TodoApp/Main.lean` - Add static file serving middleware
- `TodoApp/Views/Layout.lean` - Use proper style element instead of raw string
**Estimated Effort:** Small

### [Priority: Medium] Extract Configuration to Environment/TOML
**Current State:** Configuration is hardcoded in `TodoApp/Main.lean` including secret key ("todo-app-secret-key-min-32-chars!!") and journal path.
**Proposed Change:** Load configuration from environment variables or TOML file using the `totem` library.
**Benefits:** Security (secret key not in source), deployment flexibility, 12-factor app compliance.
**Affected Files:**
- `TodoApp/Main.lean` - Load config from environment/file
- `lakefile.lean` - Add totem dependency
- New file: `config/app.toml` - Default configuration
**Estimated Effort:** Medium
**Dependencies:** `totem` library

### [Priority: Low] Add Structured Logging
**Current State:** No logging beyond `IO.println` for startup messages.
**Proposed Change:** Integrate the `chronicle` logging library for proper request/action logging.
**Benefits:** Debugging, audit trail, production monitoring.
**Affected Files:**
- `lakefile.lean` - Add chronicle dependency
- `TodoApp/Main.lean` - Initialize logger
- Various action files - Add logging statements
**Estimated Effort:** Medium
**Dependencies:** `chronicle` library

### [Priority: Low] Improve Error Handling
**Current State:** Database errors are caught and shown as flash messages, but there's no structured error handling or error pages.
**Proposed Change:** Add proper error pages (404, 500) and consistent error handling patterns.
**Benefits:** Better UX, easier debugging, professional appearance.
**Affected Files:**
- `TodoApp/Views/` - New file `Errors.lean`
- `TodoApp/Main.lean` - Add error handling middleware
**Estimated Effort:** Small

---

## Code Cleanup

### [Priority: High] Hardcoded Secret Key Security Issue
**Issue:** The secret key is hardcoded in source code: `secretKey := "todo-app-secret-key-min-32-chars!!".toUTF8`
**Location:** `TodoApp/Main.lean`, line 17
**Action Required:** Move to environment variable or secure configuration file. Add to `.gitignore` if using config file. Document in README.
**Estimated Effort:** Small

### [Priority: Medium] Remove Inline Styles
**Issue:** Several views contain inline `style_` attributes instead of using CSS classes.
**Location:**
- `TodoApp/Views/Home.lean` - line 39 (button background)
- `TodoApp/Views/Todos.lean` - lines 42-46 (form layout), lines 60-68 (headers), line 87 (form width), line 88 (button layout)
**Action Required:** Move styles to `public/styles.css` and use semantic class names.
**Estimated Effort:** Small

### [Priority: Medium] Raw HTML String for Stylesheet Link
**Issue:** Layout uses `raw "<link rel=\"stylesheet\" href=\"/styles.css\">"` instead of proper Scribe elements.
**Location:** `TodoApp/Views/Layout.lean`, line 46
**Action Required:** Use `link_ [rel_ "stylesheet", href_ "/styles.css"]` after adding to Scribe or keep raw but document why.
**Estimated Effort:** Small

### [Priority: Medium] Missing README Route Documentation
**Issue:** README lists routes but is missing the edit routes added later.
**Location:** `README.md`, routes table (lines 48-60)
**Action Required:** Add missing routes:
- `GET /todos/:id/edit` - Edit form
- `POST /todos/:id/edit` - Update todo
**Estimated Effort:** Small

### [Priority: Low] Inconsistent Function Documentation
**Issue:** Some functions have doc comments (`/-- ... -/`) while others have regular comments (`-- ...`) or none.
**Location:** Throughout all Lean files, particularly inconsistent in `Helpers.lean`
**Action Required:** Add doc comments to all public functions for consistency and tooling support.
**Estimated Effort:** Small

### [Priority: Low] Consider Moving Test Helpers
**Issue:** Tests directly manipulate Ledger connections, duplicating patterns that could be shared.
**Location:** `Tests/Main.lean`
**Action Required:** Consider extracting test database setup patterns to a test helpers module.
**Estimated Effort:** Small

### [Priority: Low] Unused Import Cleanup
**Issue:** Some files may have unused imports that could be cleaned up.
**Location:** Verify imports in all files
**Action Required:** Review and remove any unused imports.
**Estimated Effort:** Small

---

## Test Coverage Improvements

### [Priority: High] Add View Rendering Tests
**Issue:** No tests verify that views render correctly or handle edge cases.
**Action Required:** Add tests for:
- Layout rendering with/without logged-in user
- Todo list rendering with empty list
- Todo list rendering with mixed completed/active items
- Flash message rendering
**Affected Files:** `Tests/Main.lean` or new `Tests/Views.lean`
**Estimated Effort:** Medium

### [Priority: Medium] Add Action Integration Tests
**Issue:** No tests verify action behavior with real HTTP-like contexts.
**Action Required:** Add integration tests for:
- Login with valid/invalid credentials
- Registration with duplicate email
- CSRF protection
- Todo CRUD operations
**Estimated Effort:** Medium

### [Priority: Low] Add Edge Case Tests
**Issue:** Tests don't cover edge cases like very long titles, special characters, or boundary conditions.
**Action Required:** Add tests for:
- Todo with very long title (1000+ chars)
- Todo with HTML/script injection attempt
- Password with special characters
- Email validation edge cases
**Estimated Effort:** Small

---

## Documentation Improvements

### [Priority: Medium] Add CLAUDE.md Project Instructions
**Issue:** No CLAUDE.md file exists for AI assistant context (unlike homebase-app).
**Action Required:** Create `CLAUDE.md` with:
- Build and test commands
- Architecture overview
- Common patterns
- Known issues
**Estimated Effort:** Small

### [Priority: Low] Add API Documentation
**Issue:** No documentation of the request/response format for each endpoint.
**Action Required:** Add API section to README or separate API.md documenting:
- Request parameters
- Response format
- Authentication requirements
- Error responses
**Estimated Effort:** Small

### [Priority: Low] Add Contributing Guidelines
**Issue:** No guidance for contributors on code style, testing requirements, or PR process.
**Action Required:** Add CONTRIBUTING.md with development guidelines.
**Estimated Effort:** Small

---

## Summary

### Quick Wins (Small Effort, High Value)
1. Use Route Middleware for Authentication
2. Fix Hardcoded Secret Key Security Issue
3. Add Missing README Route Documentation
4. Serve Static Files Properly

### High Impact Features
1. Add Due Dates to Todos
2. Add Todo Reordering
3. Add Server-Sent Events for Real-Time Updates

### Technical Debt to Address
1. Replace Demo Password Hashing
2. Consolidate Action Patterns (all use ActionM)
3. Add Comprehensive Input Validation

### Long-Term Enhancements
1. Add Todo Categories/Tags
2. Add Password Reset Flow
3. Add User Profile Page
4. Integrate Structured Logging
