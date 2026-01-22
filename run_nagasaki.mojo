import sys
from memory import UnsafePointer

fn main() raises:
    print("--- 🏟️ Nagasaki Stadium City: Pedestrian Simulation ---")

    # 1. ライブラリロード
    var lib_path = "build/libPhysicsOracleBridge.so"
    # import sys が必要です
    var lib = sys.ffi.DLHandle(lib_path)

    # 2. 関数取得
    var update_pedestrian = lib.get_function[fn(UnsafePointer[Float64], UnsafePointer[Float64], Float64) -> None]("update_pedestrian")
    var check_conn = lib.get_function[fn() -> Float64]("check_nagasaki_connection")

    # 3. 接続チェック
    if check_conn() == 2024.0:
        print("✅ Lean 4 Logic Connected: Ready for 2024 Opening!")
    else:
        print("❌ Connection Failed")
        return

    # 4. 歩行者パラメータ (スタジアムゲート前に静止している状態)
    var x: Float64 = 0.0  # 位置 (m)
    var v: Float64 = 0.0  # 速度 (m/s) - 最初は止まっている
    var dt: Float64 = 0.1 # 時間刻み (s)

    print("\n[Simulation Start] Match Ended. Walking towards the station...")
    print("Time(s) | Position(m) | Velocity(m/s) | Status")
    print("-------------------------------------------------------")

    # 5. ループ実行 (3秒間の動きを見る)
    for i in range(31):
        var t = i * dt
        var status = ""
        if v < 0.1:
            status = "Stopped"
        elif v < 1.4:
            status = "Accelerating"
        else:
            status = "Cruising (Steady)"

        print(t, "s  |", x, "m |", v, "m/s |", status)
        
        # Lean 4 (社会力モデル) で更新
        update_pedestrian(UnsafePointer.address_of(x), UnsafePointer.address_of(v), dt)

    print("-------------------------------------------------------")
