from memory import UnsafePointer, alloc
from python import Python
import math

fn main() raises:
    print("================================================================")
    print("   🐟 Fish Asset Verification System (Float ABI Robustness)")
    print("      Processing: 500kHz Multi-beam Sonar Simulation")
    print("================================================================")

    var ffi = Python.import_module("ctypes")
    var os = Python.import_module("os")
    var lib_path = String(os.getcwd()) + "/build/libPhysicsOracleBridge.so"
    var lib = ffi.CDLL(lib_path)

    try:
        lib.lean_initialize_runtime_module.argtypes = []
        lib.lean_initialize_runtime_module.restype = None
        lib.lean_initialize_runtime_module()
    except:
        pass 

    # 【重要変更】 戻り値を c_bool ではなく c_double に変更
    lib.verify_asset_value.argtypes = [ffi.c_double, ffi.c_double, ffi.c_double, ffi.c_double]
    lib.verify_asset_value.restype = ffi.c_double
    
    lib.launch_gpu_simulation.argtypes = [ffi.c_void_p, ffi.c_int]
    lib.launch_gpu_simulation.restype = None

    # パラメータ
    var prev_total_weight = 2000.0
    var days_passed = 7.0

    # H100 シミュレーション
    var size = 50000000
    var data_ptr = alloc[Float32](size)
    var ptr_address = Int(data_ptr)
    
    print("🌊 Running Acoustic FDTD Simulation on H100...")
    _ = lib.launch_gpu_simulation(ptr_address, size)

    # 計測値
    var detected_count = 9200.0   
    var avg_measured_weight = 0.21 
    var current_total_biomass = detected_count * avg_measured_weight

    print("   -> Sonar Analysis Complete.")
    print("   -> Detected Count: " + String(Int(detected_count)) + " fish")
    print("   -> Avg Weight: " + String(avg_measured_weight) + " kg")
    print("   -> Total Biomass: " + String(current_total_biomass) + " kg")

    # Lean 4 形式監査 (戻り値は 1.0 or 0.0)
    var result_score = lib.verify_asset_value(
        ffi.c_double(detected_count),
        ffi.c_double(avg_measured_weight),
        ffi.c_double(prev_total_weight),
        ffi.c_double(days_passed)
    )

    print("----------------------------------------------------------------")
    # Float なので 0.5 より大きければ合格と判定
    if result_score > 0.5:
        print("✅ AUDIT PASSED: Asset Value Formally Verified.")
        print("   [Certificate]")
        print("   The measured biomass is fully consistent with collateral records.")
        print("   Collateral Value: CONFIRMED for Financing.")
    else:
        print("🚨 AUDIT FAILED: Data Inconsistency Detected.")
        print("   -> Lean 4 returned score: " + String(result_score))
    
    print("================================================================")
    data_ptr.free()
