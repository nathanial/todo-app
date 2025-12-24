/-
  TodoApp.Views.Layout - HTML layout wrapper with navigation and flash messages
-/
import Scribe
import Loom

namespace TodoApp.Views.Layout

open Scribe
open Loom

/-- Render flash messages from context -/
def flashMessages (ctx : Context) : HtmlM Unit := do
  if let some msg := ctx.flash.get "success" then
    div [class_ "flash flash-success"] (text msg)
  if let some msg := ctx.flash.get "error" then
    div [class_ "flash flash-error"] (text msg)
  if let some msg := ctx.flash.get "info" then
    div [class_ "flash flash-info"] (text msg)

/-- Navigation bar -/
def navbar (ctx : Context) : HtmlM Unit :=
  nav [] do
    a [href_ "/"] (text "Todo App")
    match ctx.session.get "user_name" with
    | some userName =>
      span [class_ "nav-right"] do
        text s!"Hello, {userName} | "
        a [href_ "/todos"] (text "My Todos")
        text " | "
        a [href_ "/logout"] (text "Logout")
    | none =>
      span [class_ "nav-right"] do
        a [href_ "/login"] (text "Login")
        a [href_ "/register"] (text "Register")

/-- Main layout wrapper -/
def layout (ctx : Context) (pageTitle : String) (content : HtmlM Unit) : Html :=
  HtmlM.build do
    raw "<!DOCTYPE html>"
    html [lang_ "en"] do
      head [] do
        meta_ [charset_ "utf-8"]
        meta_ [name_ "viewport", content_ "width=device-width, initial-scale=1"]
        title pageTitle
        raw "<link rel=\"stylesheet\" href=\"/styles.css\">"
      body [] do
        navbar ctx
        div [class_ "container"] do
          flashMessages ctx
          content

/-- Render layout to string -/
def render (ctx : Context) (pageTitle : String) (content : HtmlM Unit) : String :=
  (layout ctx pageTitle content).render

end TodoApp.Views.Layout
