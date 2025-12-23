/-
  TodoApp.Views.Todos - Todo list and form views
-/
import Scribe
import Loom
import TodoApp.Views.Layout
import TodoApp.Helpers

namespace TodoApp.Views.Todos

open Scribe
open Loom
open TodoApp.Views.Layout
open TodoApp.Helpers

/-- Render a single todo item -/
def todoItem (ctx : Context) (todo : TodoData) : HtmlM Unit := do
  let completedClass := if todo.completed then "todo-item completed" else "todo-item"
  div [class_ completedClass] do
    span [class_ "todo-title"] (text todo.title)
    div [class_ "todo-actions"] do
      -- Toggle completion form
      form [method_ "post", action_ s!"/todos/{todo.id.id}/toggle"] do
        csrfField ctx.csrfToken
        if todo.completed then
          button [type_ "submit", class_ "btn btn-small"] (text "Undo")
        else
          button [type_ "submit", class_ "btn btn-success btn-small"] (text "Done")
      -- Delete form
      form [method_ "post", action_ s!"/todos/{todo.id.id}/delete"] do
        csrfField ctx.csrfToken
        button [type_ "submit", class_ "btn btn-danger btn-small"] (text "Delete")

/-- Todos index page content -/
def indexContent (ctx : Context) (todos : List TodoData) : HtmlM Unit := do
  h1 [] (text "My Todos")

  -- Add new todo form
  div [class_ "card"] do
    h2 [style_ "font-size: 18px; margin-bottom: 15px;"] (text "Add New Todo")
    form [method_ "post", action_ "/todos", style_ "display: flex; gap: 10px;"] do
      csrfField ctx.csrfToken
      input [type_ "text", name_ "title", placeholder_ "What needs to be done?",
             required_, style_ "flex: 1; margin-bottom: 0;"]
      button [type_ "submit"] (text "Add")

  -- Todo list
  if todos.isEmpty then
    div [class_ "card"] do
      p [class_ "text-muted"] (text "No todos yet. Add one above!")
  else
    let activeTodos := todos.filter (! ·.completed)
    let completedTodos := todos.filter (·.completed)

    -- Active todos
    if !activeTodos.isEmpty then
      div [class_ "mb-2"] do
        h2 [style_ "font-size: 16px; margin-bottom: 10px; color: #666;"] do
          text s!"Active ({activeTodos.length})"
        for todo in activeTodos do
          todoItem ctx todo

    -- Completed todos
    if !completedTodos.isEmpty then
      div [] do
        h2 [style_ "font-size: 16px; margin-bottom: 10px; color: #666;"] do
          text s!"Completed ({completedTodos.length})"
        for todo in completedTodos do
          todoItem ctx todo

/-- Render todos index page -/
def renderIndex (ctx : Context) (todos : List TodoData) : String :=
  Layout.render ctx "My Todos - Todo App" (indexContent ctx todos)

end TodoApp.Views.Todos
