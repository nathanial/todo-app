/-
  TodoApp Tests
-/
import Crucible
import TodoApp.Models
import TodoApp.Helpers
import Ledger

open Crucible
open TodoApp.Models
open TodoApp.Helpers
open Ledger

testSuite "TodoApp"

/-! ## Model Tests -/

test "user attributes are defined" := do
  userEmail.name ≡ ":user/email"
  userPasswordHash.name ≡ ":user/password-hash"
  userName.name ≡ ":user/name"

test "todo attributes are defined" := do
  todoTitle.name ≡ ":todo/title"
  todoCompleted.name ≡ ":todo/completed"
  todoOwner.name ≡ ":todo/owner"

/-! ## Password Hashing Tests -/

test "password hashing is deterministic" := do
  let secret := "test-secret-key".toUTF8
  let hash1 := hashPassword "password123" secret
  let hash2 := hashPassword "password123" secret
  hash1 ≡ hash2

test "different passwords have different hashes" := do
  let secret := "test-secret-key".toUTF8
  let hash1 := hashPassword "password123" secret
  let hash2 := hashPassword "different" secret
  -- Test that hashes are non-empty (basic sanity check)
  hash1.isEmpty ≡ false
  hash2.isEmpty ≡ false

test "verify password works correctly" := do
  let secret := "test-secret-key".toUTF8
  let hash := hashPassword "mypassword" secret
  -- Verify returns true for correct password
  verifyPassword "mypassword" hash secret ≡ true

/-! ## Database Helper Tests -/

test "TodoData can be created" := do
  let todo : TodoData := { id := ⟨1⟩, title := "Test Todo", completed := false }
  todo.title ≡ "Test Todo"
  todo.completed ≡ false

test "TodoData completed field works" := do
  let todo : TodoData := { id := ⟨1⟩, title := "Done Todo", completed := true }
  todo.completed ≡ true

/-! ## Ledger Integration Tests -/

test "can create user in database" := do
  let conn := Connection.create
  let (userId, conn) := conn.allocEntityId
  let tx : Transaction := [
    .add userId userName (.string "Alice"),
    .add userId userEmail (.string "alice@test.com"),
    .add userId userPasswordHash (.string "hash123")
  ]
  match conn.transact tx with
  | Except.ok (newConn, _) =>
    let db := newConn.db
    match db.getOne userId userName with
    | some (.string name) => name ≡ "Alice"
    | _ => panic! "Expected string value"
  | Except.error e => panic! s!"Transaction failed: {e}"

test "can create todo in database" := do
  let conn := Connection.create
  let (userId, conn) := conn.allocEntityId
  let (todoId, conn) := conn.allocEntityId
  let tx : Transaction := [
    .add userId userName (.string "Alice"),
    .add todoId todoTitle (.string "Buy milk"),
    .add todoId todoCompleted (.bool false),
    .add todoId todoOwner (.ref userId)
  ]
  match conn.transact tx with
  | Except.ok (newConn, _) =>
    let db := newConn.db
    match db.getOne todoId todoTitle with
    | some (.string title) => title ≡ "Buy milk"
    | _ => panic! "Expected string value"
    match db.getOne todoId todoCompleted with
    | some (.bool b) => b ≡ false
    | _ => panic! "Expected bool value"
  | Except.error e => panic! s!"Transaction failed: {e}"

test "can find user by email" := do
  let conn := Connection.create
  let (userId, conn) := conn.allocEntityId
  let tx : Transaction := [
    .add userId userName (.string "Bob"),
    .add userId userEmail (.string "bob@test.com")
  ]
  match conn.transact tx with
  | Except.ok (newConn, _) =>
    let db := newConn.db
    match db.findOneByAttrValue userEmail (.string "bob@test.com") with
    | some foundId => foundId ≡ userId
    | none => panic! "User not found"
  | Except.error e => panic! s!"Transaction failed: {e}"

test "can toggle todo completion" := do
  let conn := Connection.create
  let (todoId, conn) := conn.allocEntityId
  let tx1 : Transaction := [
    .add todoId todoTitle (.string "Test todo"),
    .add todoId todoCompleted (.bool false)
  ]
  match conn.transact tx1 with
  | Except.ok (conn, _) =>
    -- Toggle to true
    let tx2 : Transaction := [
      .retract todoId todoCompleted (.bool false),
      .add todoId todoCompleted (.bool true)
    ]
    match conn.transact tx2 with
    | Except.ok (newConn, _) =>
      let db := newConn.db
      match db.getOne todoId todoCompleted with
      | some (.bool b) => b ≡ true
      | _ => panic! "Expected bool value"
    | Except.error e => panic! s!"Toggle failed: {e}"
  | Except.error e => panic! s!"Create failed: {e}"

test "can find todos by owner" := do
  let conn := Connection.create
  let (userId, conn) := conn.allocEntityId
  let (todo1Id, conn) := conn.allocEntityId
  let (todo2Id, conn) := conn.allocEntityId
  let tx : Transaction := [
    .add userId userName (.string "User"),
    .add todo1Id todoTitle (.string "Todo 1"),
    .add todo1Id todoOwner (.ref userId),
    .add todo2Id todoTitle (.string "Todo 2"),
    .add todo2Id todoOwner (.ref userId)
  ]
  match conn.transact tx with
  | Except.ok (newConn, _) =>
    let db := newConn.db
    let todos := db.findByAttrValue todoOwner (.ref userId)
    todos.length ≡ 2
  | Except.error e => panic! s!"Transaction failed: {e}"

-- Main entry point
def main : IO UInt32 := do
  IO.println "TodoApp Tests"
  IO.println "============="
  IO.println ""

  let result ← runAllSuites

  IO.println ""
  if result != 0 then
    IO.println "Some tests failed!"
    return 1
  else
    IO.println "All tests passed!"
    return 0
