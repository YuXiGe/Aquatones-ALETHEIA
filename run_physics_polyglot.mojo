from python import Python

fn main() raises:
    print("--- 🚀 Mojo (via Python ctypes) + Lean 4 ---")
    
    # 1. Pythonの ctypes モジュールをMojo内にインポート
    # これにより、Mojoのバージョンに依存せず確実にライブラリをロードできます
    var ctypes = Python.import_module("ctypes")
    
    # 2. 共有ライブラリのロード
    # "./" をつけてカレントディレクトリを明示するのがコツです
    var lib_path = "./build/libPhysicsOracleBridge.so"
    var lib = ctypes.CDLL(lib_path)
    
    # 3. 関数の戻り値の型設定 (LeanのFloatはCのdouble)
    lib.call_lean_oracle.restype = ctypes.c_double
    
    # 初期化チェック
    var check = lib.call_lean_oracle()
    print("Lean Runtime Init Check:", check)
    
    # 4. 変数の準備 (ctypes.c_double を使用)
    var q = ctypes.c_double(1.0)
    var p = ctypes.c_double(0.0)
    var dt = ctypes.c_double(0.05)
    
    print("\nStarting Simulation loop...")
    print("-----------------------------------------")
    
    # 5. シミュレーションループ
    for i in range(21):
        # .value で中身の値にアクセス
        print("Step", i, "| q:", q.value, "| p:", p.value)
        
        # ctypes.byref でポインタ(参照)を渡します
        # これで C++ 側の double* に対応します
        lib.simulate_oscillator_step(ctypes.byref(q), ctypes.byref(p), dt)
        
    print("-----------------------------------------")
    print("Simulation Completed Successfully.")
