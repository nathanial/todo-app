/-
  TodoApp.Actions.Todos - Todo CRUD actions using ActionM
-/
import Loom
import Ledger
import TodoApp.Models
import TodoApp.Helpers
import TodoApp.Views.Todos

namespace TodoApp.Actions.Todos

open Loom
open Loom.ActionM
open Ledger
open TodoApp.Models
open TodoApp.Helpers

/-! ## Helper functions -/

/-- Get and parse user ID from session -/
private def requireUserId : ActionM (Option Int) := do
  let some userIdStr ← sessionGet "user_id" | return none
  let some userId := userIdStr.toInt? | return none
  return some userId

/-- Verify current user owns the given todo. Returns the database on success. -/
private def verifyOwnership (todoId : EntityId) (userId : Int) : ActionM (Option Db) := do
  let some db ← database | return none
  match db.getOne todoId todoOwner with
  | some (.ref ownerId) => if ownerId.id == userId then pure (some db) else pure none
  | _ => pure none

/-- Helper to load todo data from context -/
private def loadTodoM (todoId : EntityId) : ActionM (Option TodoData) := do
  let ctx ← getCtx
  pure (loadTodo ctx todoId)

/-! ## Actions -/

/-- List all todos for current user -/
def index : ActionM Herald.Core.Response := do
  let some userId ← requireUserId | return ← redirect "/login"
  let ctx ← getCtx
  let todos := loadUserTodos ctx ⟨userId⟩
  let htmlContent := TodoApp.Views.Todos.renderIndex ctx todos
  html htmlContent

/-- Create a new todo -/
def create : ActionM Herald.Core.Response := do
  let title ← paramD "title" ""
  if title.isEmpty then
    flashError "Todo title is required"
    return ← redirect "/todos"

  let some userId ← requireUserId | return ← redirect "/login"
  let some todoId ← allocEntityId | do
    flashError "Database not available"
    return ← redirect "/todos"

  let tx : Transaction := [
    .add todoId todoTitle (.string title),
    .add todoId todoCompleted (.bool false),
    .add todoId todoOwner (.ref ⟨userId⟩)
  ]
  match ← transact tx with
  | .ok () => flashSuccess "Todo added!"; redirect "/todos"
  | .error e => flashError s!"Failed to add todo: {e}"; redirect "/todos"

/-- Toggle todo completion -/
def toggle : ActionM Herald.Core.Response := do
  let some todoIdInt := (← paramD "id" "").toInt? | do
    flashError "Invalid todo"
    return ← redirect "/todos"
  let todoId : EntityId := ⟨todoIdInt⟩

  let some userId ← requireUserId | return ← redirect "/login"
  let some db ← verifyOwnership todoId userId | do
    flashError "Not authorized"
    return ← redirect "/todos"

  let currentCompleted := match db.getOne todoId todoCompleted with
    | some (Value.bool b) => b
    | _ => false
  let newCompleted := !currentCompleted

  let tx : Transaction := [
    .retract todoId todoCompleted (.bool currentCompleted),
    .add todoId todoCompleted (.bool newCompleted)
  ]
  match ← transact tx with
  | .ok () =>
    let msg := if newCompleted then "Todo completed!" else "Todo marked as active"
    flashSuccess msg
    redirect "/todos"
  | .error e =>
    flashError s!"Failed to update todo: {e}"
    redirect "/todos"

/-- Delete a todo -/
def delete : ActionM Herald.Core.Response := do
  let some todoIdInt := (← paramD "id" "").toInt? | do
    flashError "Invalid todo"
    return ← redirect "/todos"
  let todoId : EntityId := ⟨todoIdInt⟩

  let some userId ← requireUserId | return ← redirect "/login"
  let some db ← verifyOwnership todoId userId | do
    flashError "Not authorized"
    return ← redirect "/todos"

  -- Build retraction for all current values
  let txOps := [todoTitle, todoCompleted, todoOwner].filterMap fun attr =>
    db.getOne todoId attr |>.map fun v => TxOp.retract todoId attr v

  match ← transact txOps with
  | .ok () => flashSuccess "Todo deleted"; redirect "/todos"
  | .error e => flashError s!"Failed to delete todo: {e}"; redirect "/todos"

/-- Show edit form for a todo -/
def editForm : ActionM Herald.Core.Response := do
  let some todoIdInt := (← paramD "id" "").toInt? | do
    flashError "Invalid todo"
    return ← redirect "/todos"
  let todoId : EntityId := ⟨todoIdInt⟩

  let some userId ← requireUserId | return ← redirect "/login"
  let some _ ← verifyOwnership todoId userId | do
    flashError "Not authorized"
    return ← redirect "/todos"
  let some todo ← loadTodoM todoId | do
    flashError "Todo not found"
    return ← redirect "/todos"

  let ctx ← getCtx
  let htmlContent := TodoApp.Views.Todos.renderEditForm ctx todo
  html htmlContent

/-- Update a todo's title -/
def edit : ActionM Herald.Core.Response := do
  let todoIdStr ← paramD "id" ""
  let newTitle ← paramD "title" ""

  if newTitle.isEmpty then
    flashError "Todo title is required"
    return ← redirect s!"/todos/{todoIdStr}/edit"

  let some todoIdInt := todoIdStr.toInt? | do
    flashError "Invalid todo"
    return ← redirect "/todos"
  let todoId : EntityId := ⟨todoIdInt⟩

  let some userId ← requireUserId | return ← redirect "/login"
  let some db ← verifyOwnership todoId userId | do
    flashError "Not authorized"
    return ← redirect "/todos"
  let some (Value.string oldTitle) := db.getOne todoId todoTitle | do
    flashError "Todo not found"
    return ← redirect "/todos"

  let tx : Transaction := [
    .retract todoId todoTitle (.string oldTitle),
    .add todoId todoTitle (.string newTitle)
  ]
  match ← transact tx with
  | .ok () => flashSuccess "Todo updated!"; redirect "/todos"
  | .error e => flashError s!"Failed to update todo: {e}"; redirect "/todos"

end TodoApp.Actions.Todos
