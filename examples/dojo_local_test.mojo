from python import Python

fn main() raises:
    var lean_dojo = Python.import_module("lean_dojo")
    print("--- ⚔️ Dojo Local Interaction ---")
    try:
        var dojo = lean_dojo.Dojo("src/SimpleOracle.lean", "validate_physics")
        var state = dojo.__enter__()
        print("Initial State:", state)
        dojo.__exit__(None, None, None)
    except e:
        print("Error:", e)
