from memory import UnsafePointer, alloc
from python import Python

fn main() raises:
    print("================================================================")
    print("   🕵️ AQUATONES-ALETHEIA: ABI Condition Coverage Probe (Fixed)")
    print("================================================================")
    
    var ffi = Python.import_module("ctypes")
    var os = Python.import_module("os")
    var lib_path = String(os.getcwd()) + "/build/libPhysicsOracleBridge.so"
    var lib = ffi.CDLL(lib_path)

    # ---------------------------------------------------------
    # [L1] UInt8 Baseline
    # Lean: def probe_u8_baseline (_ : Unit) : UInt8
    # Fix:  Unit引数を受け取るため、void* を1つ渡す
    # ---------------------------------------------------------
    lib.probe_u8_baseline.argtypes = [ffi.c_void_p] 
    lib.probe_u8_baseline.restype = ffi.c_uint8
    
    # 0 (Null Pointer) を Unit の代わりとして渡す
    var l1_res = Int(lib.probe_u8_baseline(0))
    var l1_pass = (l1_res == 1)
    
    print("[L1] UInt8 Baseline       | Expected: 1       | Actual: " + String(l1_res) + " | " + ("✅ PASS" if l1_pass else "❌ FAIL"))

    # ---------------------------------------------------------
    # [L2] Float Constant
    # Lean: def probe_float_const (_ : Unit) : Float
    # Fix:  ここも Unit 引数が必要
    # ---------------------------------------------------------
    lib.probe_float_const.argtypes = [ffi.c_void_p]
    lib.probe_float_const.restype = ffi.c_double 

    var l2_py = lib.probe_float_const(0)
    var l2_res = Float64(l2_py)
    var l2_expected = 123.456
    var l2_pass = abs(l2_res - l2_expected) < 0.001

    print("[L2] Float Constant       | Expected: 123.456 | Actual: " + String(l2_res) + " | " + ("✅ PASS" if l2_pass else "❌ FAIL"))

    # ---------------------------------------------------------
    # [L3] Float Identity (x=x)
    # Lean: def probe_float_identity (x : Float) : Float
    # Note: Float引数はそのまま渡してOK（LeanのFloatはunboxed doubleとして扱われる場合が多いが、要検証）
    # ---------------------------------------------------------
    lib.probe_float_identity.argtypes = [ffi.c_double]
    lib.probe_float_identity.restype = ffi.c_double

    var l3_input = 99.99
    var l3_py = lib.probe_float_identity(ffi.c_double(l3_input))
    var l3_res = Float64(l3_py)
    var l3_pass = abs(l3_res - l3_input) < 0.001

    print("[L3] Float Identity (x=x) | Expected: " + String(l3_input) + "   | Actual: " + String(l3_res) + " | " + ("✅ PASS" if l3_pass else "❌ FAIL"))

    # ---------------------------------------------------------
    # [L4] Float Add (a+b)
    # ---------------------------------------------------------
    lib.probe_float_add.argtypes = [ffi.c_double, ffi.c_double]
    lib.probe_float_add.restype = ffi.c_double

    var l4_a = 10.0
    var l4_b = 20.0
    var l4_py = lib.probe_float_add(ffi.c_double(l4_a), ffi.c_double(l4_b))
    var l4_res = Float64(l4_py)
    var l4_pass = abs(l4_res - 30.0) < 0.001

    print("[L4] Float Add (a+b)      | Expected: 30.0    | Actual: " + String(l4_res) + "  | " + ("✅ PASS" if l4_pass else "❌ FAIL"))
    
    print("================================================================")
