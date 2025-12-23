import Lake
open Lake DSL

package todoApp where
  version := v!"0.1.0"

require loom from ".." / "loom"
require crucible from ".." / "crucible"

@[default_target]
lean_lib TodoApp where
  roots := #[`TodoApp]

lean_lib Tests where
  globs := #[.submodules `Tests]

@[test_driver]
lean_exe tests where
  root := `Tests.Main

lean_exe todoApp where
  root := `TodoApp.Main
