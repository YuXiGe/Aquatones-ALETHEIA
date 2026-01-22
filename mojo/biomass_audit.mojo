from memory import UnsafePointer, alloc
from python import Python

fn main() raises:
    print("================================================================")
    print("   🐟 AQUATONES-ALETHEIA: Biomass Asset Audit Engine")
    print("      Verification Level: Formal Logic (Integer Mode)")
    print("================================================================")
    
    var ffi = Python.import_module("ctypes")
    var os = Python.import_module("os")
    var lib_path = String(os.getcwd()) + "/build/libPhysicsOracleBridge.so"
    var lib = ffi.CDLL(lib_path)

    # 【重要】戻り値を c_uint8 (8bit整数) として定義
    lib.verify_asset_value.argtypes = [ffi.c_double, ffi.c_double, ffi.c_double, ffi.c_double]
    lib.verify_asset_value.restype = ffi.c_uint8

    # データセット
    var count: Float64 = 9200.0
    var avg_weight: Float64 = 0.21
    
    print("📊 Measurement Data:")
    print("   -> Detected Count: " + String(Int(count)) + " fish")
    print("----------------------------------------------------------------")

    # 実行
    var result_code = lib.verify_asset_value(
        ffi.c_double(count), 
        ffi.c_double(avg_weight), 
        ffi.c_double(2000.0), 
        ffi.c_double(7.0)
    )
    
    # 判定
    var status = Int(result_code)

    if status == 1:
        print("✅ AUDIT PASSED: Asset value is formally verified.")
        print("   [Certification Report]")
        print("   - Logic Return Code: 1 (SUCCESS)")
        print("   - Collateral Status: ELIGIBLE FOR FINANCING")
    else:
        print("🚨 AUDIT FAILED: Return Code " + String(status))
    
    print("================================================================")
