/-
  TodoApp.Main - Application setup and entry point
-/
import Loom
import TodoApp.Helpers
import TodoApp.Actions.Home
import TodoApp.Actions.Auth
import TodoApp.Actions.Todos

namespace TodoApp

open Loom
open TodoApp.Helpers

/-- Application configuration -/
def config : AppConfig := {
  secretKey := "todo-app-secret-key-min-32-chars!!".toUTF8
  sessionCookieName := "todo_session"
  csrfFieldName := "_csrf"
  csrfEnabled := true
}

/-- Shared database connection reference -/
def sharedDbRef : IO (IO.Ref Ledger.Connection) :=
  IO.mkRef Ledger.Connection.create

/-- Build the application with all routes using shared database -/
def buildApp (dbRef : IO.Ref Ledger.Connection) : App :=
  -- Create a factory that returns the shared connection
  let sharedFactory : Database.ConnectionFactory := dbRef.get
  Loom.app config
    -- Middleware
    |>.use Middleware.logging
    |>.use Middleware.securityHeaders
    -- Public routes
    |>.get "/" "home" Actions.Home.index
    |>.get "/login" "login_form" Actions.Auth.loginForm
    |>.post "/login" "login" (Actions.Auth.loginWithRef dbRef)
    |>.get "/register" "register_form" Actions.Auth.registerForm
    |>.post "/register" "register" (Actions.Auth.registerWithRef dbRef)
    |>.get "/logout" "logout" Actions.Auth.logout
    -- Protected routes (auth check happens in actions)
    |>.get "/todos" "todos_index" Actions.Todos.index
    |>.post "/todos" "todos_create" (Actions.Todos.createWithRef dbRef)
    |>.post "/todos/:id/toggle" "todos_toggle" (Actions.Todos.toggleWithRef dbRef)
    |>.post "/todos/:id/delete" "todos_delete" (Actions.Todos.deleteWithRef dbRef)
    -- Database with shared factory
    |>.withDatabase sharedFactory

/-- Main entry point (inside namespace) -/
def runApp : IO Unit := do
  IO.println "Starting Todo App..."
  IO.println "Database: In-memory (shared across requests)"
  let dbRef ← sharedDbRef
  let app := buildApp dbRef
  app.run "0.0.0.0" 3000

end TodoApp

/-- Top-level main entry point for executable -/
def main : IO Unit := TodoApp.runApp
