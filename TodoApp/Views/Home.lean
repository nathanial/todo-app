/-
  TodoApp.Views.Home - Home page view
-/
import Scribe
import Loom
import TodoApp.Views.Layout

namespace TodoApp.Views.Home

open Scribe
open Loom
open TodoApp.Views.Layout

/-- Home page content -/
def homeContent (ctx : Context) : HtmlM Unit := do
  div [class_ "card"] do
    h1 [] (text "Welcome to Todo App")
    p [] do
      text "A simple todo application built with "
      strong [] (text "Lean 4")
      text ", "
      strong [] (text "Loom")
      text " (web framework), and "
      strong [] (text "Ledger")
      text " (database)."

    div [class_ "mt-2"] do
      match ctx.session.get "user_id" with
      | some _ =>
        p [] do
          text "You are logged in. "
          a [href_ "/todos", class_ "btn"] (text "Go to My Todos")
      | none =>
        p [] do
          text "Get started by creating an account or logging in."
        div [class_ "mt-2"] do
          a [href_ "/register", class_ "btn"] (text "Register")
          text " "
          a [href_ "/login", class_ "btn", style_ "background: #6c757d"] (text "Login")

/-- Render home page -/
def render (ctx : Context) : String :=
  Layout.render ctx "Todo App - Home" (homeContent ctx)

end TodoApp.Views.Home
