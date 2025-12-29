import Lake
open Lake DSL

package todoApp where
  version := v!"0.1.0"

require loom from git "https://github.com/nathanial/loom" @ "v0.0.1"
require crucible from git "https://github.com/nathanial/crucible" @ "v0.0.1"

-- OpenSSL linking (required by citadel's TLS support via loom)
-- Lake doesn't propagate moreLinkArgs from dependencies, so we must add them here
def opensslLinkArgs : Array String :=
  #["-L/opt/homebrew/opt/openssl@3/lib", "-lssl", "-lcrypto"]

@[default_target]
lean_lib TodoApp where
  roots := #[`TodoApp]
  moreLinkArgs := opensslLinkArgs

lean_lib Tests where
  globs := #[.submodules `Tests]

@[test_driver]
lean_exe tests where
  root := `Tests.Main
  moreLinkArgs := opensslLinkArgs

lean_exe todoApp where
  root := `TodoApp.Main
  moreLinkArgs := opensslLinkArgs
