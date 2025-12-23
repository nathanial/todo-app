/-
  TodoApp.Actions.Home - Home page action
-/
import Loom
import TodoApp.Views.Home

namespace TodoApp.Actions.Home

open Loom

/-- Home page action -/
def index : Action := fun ctx => do
  let html := TodoApp.Views.Home.render ctx
  Action.html html ctx

end TodoApp.Actions.Home
