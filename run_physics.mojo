# sys を明示的にインポートすることで 'unknown declaration sys' を防ぎます
import sys
from memory import UnsafePointer

fn main() raises:
    print("--- 🚀 Mojo + Lean 4 Physics Oracle ---")

    # 1. 共有ライブラリのロード
    var lib_path = "build/libPhysicsOracleBridge.so"
    
    # DLHandle の場所はバージョンにより異なるため、
    # sys.ffi.DLHandle でアクセスします（import sys があれば解決できるはずです）
    var lib = sys.ffi.DLHandle(lib_path)

    # 2. 関数の取得
    # C++: void simulate_oscillator_step(double* q, double* p, double dt)
    var simulate = lib.get_function[fn(UnsafePointer[Float64], UnsafePointer[Float64], Float64) -> None]("simulate_oscillator_step")
    
    # 初期化関数
    var init_oracle = lib.get_function[fn() -> Float64]("call_lean_oracle")
    
    # 初期化実行
    var check = init_oracle()
    print("Lean Runtime Init Check:", check)

    # 3. 物理変数の定義
    var q: Float64 = 1.0
    var p: Float64 = 0.0
    var dt: Float64 = 0.05

    print("\nStarting Simulation loop inside Mojo...")
    print("-----------------------------------------")

    # 4. シミュレーションループ
    for i in range(21):
        print("Step", i, "| q:", q, "| p:", p)
        simulate(UnsafePointer.address_of(q), UnsafePointer.address_of(p), dt)
    
    print("-----------------------------------------")
    print("Simulation Completed.")
