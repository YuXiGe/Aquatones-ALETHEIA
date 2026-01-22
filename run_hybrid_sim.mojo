from memory import UnsafePointer, alloc
from python import Python
import math

fn main() raises:
    print("================================================================")
    print("   🏙️  Nagasaki City OS: Hybrid Physics Engine (Python Bridge)")
    print("   HARDWARE: NVIDIA H100 NVL + Intel Xeon Gold")
    print("================================================================")

    # -----------------------------------------------------
    # Step 0: Load Library via Python
    # -----------------------------------------------------
    print("🐍 Python: Loading CUDA Bridge Library...")
    
    var ffi = Python.import_module("ctypes")
    var os = Python.import_module("os")
    
    var cwd = String(os.getcwd())
    var lib_path = cwd + "/build/libPhysicsOracleBridge.so"
    var lib = ffi.CDLL(lib_path)
    
    # ctypesの型定義
    lib.launch_gpu_simulation.argtypes = [ffi.c_void_p, ffi.c_int]
    lib.launch_gpu_simulation.restype = None

    # -----------------------------------------------------
    # Simulation Setup
    # -----------------------------------------------------
    var grid_width = 10000
    var size = grid_width * grid_width
    var data_ptr = alloc[Float32](size)

    # -----------------------------------------------------
    # Phase A: CPU Initialization
    # -----------------------------------------------------
    print("⚡ [CPU] Initializing " + String(size) + " voxels...")
    for i in range(size):
        var val = math.sin(Float32(i) * 0.0001) * 100.0 + math.cos(Float32(i) * 0.005) * 50.0
        data_ptr.store(i, val)
    
    print("   -> Check Voxel[12345]: " + String(data_ptr[12345]))

    # -----------------------------------------------------
    # Phase B: GPU Simulation (Mojo -> Python -> CUDA)
    # -----------------------------------------------------
    print("🌊 [GPU] Handing over to NVIDIA H100...")

    # 【重要】ポインタのアドレスを数値として取得
    # UnsafePointer を Int (Pythonの整数に対応) に変換します
    var ptr_address = Int(data_ptr)

    for i in range(10):
        # Python に数値を渡すことで、ctypes が c_void_p として扱ってくれます
        _ = lib.launch_gpu_simulation(ptr_address, size)
        
        # 物理演算の結果を確認
        print("   [Step " + String(i+1) + "] Voxel[12345] Density: " + String(data_ptr[12345]))

    print("✅ Simulation Completed Successfully.")
    
    data_ptr.free()
