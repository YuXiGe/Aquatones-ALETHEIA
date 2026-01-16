import Lake
open Lake DSL

package physics_oracle where
  precompileModules := true

@[default_target]
lean_lib PhysicsOracle where

require scilean from ".." / "SciLean"
