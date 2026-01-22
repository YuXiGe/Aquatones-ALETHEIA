from memory import UnsafePointer, alloc
from python import Python

fn main() raises:
    var ffi = Python.import_module("ctypes")
    var os = Python.import_module("os")
    var lib = ffi.CDLL(String(os.getcwd()) + "/build/libPhysicsOracleBridge.so")

    # 型定義の再確認
    lib.tdd_scilean_add.argtypes = [ffi.c_double, ffi.c_double]
    lib.tdd_scilean_add.restype = ffi.c_double

    # テスト実行
    var a = 1.1
    var b = 2.2
    var result = lib.tdd_scilean_add(ffi.c_double(a), ffi.c_double(b))

    print("--- 🧪 TDD: SciLean FFI Test ---")
    print("Input A: " + String(a))
    print("Input B: " + String(b))
    print("Result:  " + String(result))

    if result == (a + b):
        print("✅ TEST PASSED: SciLean Float ABI is consistent with c_double.")
    else:
        print("❌ TEST FAILED: Value corruption detected!")
