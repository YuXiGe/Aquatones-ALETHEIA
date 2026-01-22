import Lake
open Lake DSL

package PhysicsOracle where
  moreLeancArgs := #["-I.pixi/envs/default/include", "-fPIC"]
  moreLinkArgs := #["-L.pixi/envs/default/lib", "-lopenblas"]

require scilean from git
  "https://github.com/lecopivo/SciLean.git" @ "master"

@[default_target]
lean_lib PhysicsOracle where
  precompileModules := true
  srcDir := "src"
  roots := #[`SimpleOracle]
