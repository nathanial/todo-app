/-
  TodoApp.Models - Entity attribute definitions

  Defines the Ledger attributes for Users and Todos.
-/
import Ledger

namespace TodoApp.Models

open Ledger

-- User attributes
def userEmail : Attribute := ⟨":user/email"⟩
def userPasswordHash : Attribute := ⟨":user/password-hash"⟩
def userName : Attribute := ⟨":user/name"⟩

-- Todo attributes
def todoTitle : Attribute := ⟨":todo/title"⟩
def todoCompleted : Attribute := ⟨":todo/completed"⟩
def todoOwner : Attribute := ⟨":todo/owner"⟩

end TodoApp.Models
