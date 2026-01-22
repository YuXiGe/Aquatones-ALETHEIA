from memory import UnsafePointer, alloc
from python import Python

fn main() raises:
    print("--- 🧪 TDD: SciLean FFI Connectivity Test ---")
    
    var ffi = Python.import_module("ctypes")
    var os = Python.import_module("os")
    
    # ブリッジライブラリのロード
    var lib_path = String(os.getcwd()) + "/build/libPhysicsOracleBridge.so"
    var lib = ffi.CDLL(lib_path)

    # 型の定義: SciLean の Float (64bit) は Mojo の c_double に対応 [cite: 5]
    lib.tdd_scilean_add.argtypes = [ffi.c_double, ffi.c_double]
    lib.tdd_scilean_add.restype = ffi.c_double

    # テスト値の設定
    var val1: Float64 = 123.456
    var val2: Float64 = 789.012
    var expected: Float64 = val1 + val2
    
    # SciLean 関数の呼び出し
    var py_result = lib.tdd_scilean_add(ffi.c_double(val1), ffi.c_double(val2))

    # 【修正】PythonObject を Mojo の Float64 へ変換
    var result = Float64(py_result)

    print("Input A:  " + String(val1))
    print("Input B:  " + String(val2))
    print("Result:   " + String(result))
    print("Expected: " + String(expected))

    # Mojo ネイティブな比較と絶対値計算
    var diff = result - expected
    var absolute_diff = diff if diff >= 0 else -diff

    if absolute_diff < 0.000001:
        print("✅ SUCCESS: SciLean and Mojo are perfectly synchronized!")
    else:
        print("❌ FAILED: ABI mismatch detected. Diff: " + String(absolute_diff))
