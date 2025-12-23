# Todo App

A simple todo web application built with Lean 4, demonstrating the use of:

- **Loom** - Rails-like web framework
- **Ledger** - Datomic-like fact-based database
- **Citadel** - HTTP server
- **Scribe** - HTML generation

## Features

- User registration and login (session-based authentication)
- CRUD operations for todos
- User-scoped todo lists
- Flash messages for user feedback
- CSRF protection
- Basic inline CSS styling

## Requirements

- Lean 4.26.0
- Lake (included with Lean)

## Building

```bash
# Build the library
lake build

# Build the executable
lake build todoApp

# Run tests
lake test
```

## Running

```bash
# Start the server
.lake/build/bin/todoApp
```

The server will start on `http://0.0.0.0:3000`.

## Routes

| Method | Path | Description |
|--------|------|-------------|
| GET | `/` | Home page |
| GET | `/login` | Login form |
| POST | `/login` | Authenticate user |
| GET | `/register` | Registration form |
| POST | `/register` | Create new account |
| GET | `/logout` | Log out |
| GET | `/todos` | List user's todos |
| POST | `/todos` | Create new todo |
| POST | `/todos/:id/toggle` | Toggle todo completion |
| POST | `/todos/:id/delete` | Delete todo |

## Project Structure

```
todo-app/
├── lakefile.lean           # Package configuration
├── lean-toolchain          # Lean version
├── TodoApp.lean            # Root module
├── TodoApp/
│   ├── Models.lean         # Database attribute definitions
│   ├── Helpers.lean        # Auth guards, password hashing, utilities
│   ├── Actions/
│   │   ├── Home.lean       # Home page action
│   │   ├── Auth.lean       # Login, register, logout
│   │   └── Todos.lean      # Todo CRUD actions
│   ├── Views/
│   │   ├── Layout.lean     # HTML layout with CSS
│   │   ├── Home.lean       # Home page view
│   │   ├── Auth.lean       # Login/register forms
│   │   └── Todos.lean      # Todo list views
│   └── Main.lean           # App configuration and routes
└── Tests/
    └── Main.lean           # Test suite
```

## Database Schema

The app uses Ledger's fact-based database with the following attributes:

**User:**
- `:user/email` - User's email address
- `:user/password-hash` - Hashed password
- `:user/name` - Display name

**Todo:**
- `:todo/title` - Todo title
- `:todo/completed` - Completion status (boolean)
- `:todo/owner` - Reference to user entity

## Dependencies

- [Loom](../loom) - Web framework
- [Ledger](../ledger) - Database (via Loom)
- [Citadel](../citadel) - HTTP server (via Loom)
- [Scribe](../scribe) - HTML generation (via Loom)
- [Crucible](../crucible) - Test framework

## License

MIT License - see [LICENSE](LICENSE)
