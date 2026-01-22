from python import Python

fn main() raises:
    print("--- 🏟️ Nagasaki Stadium City: Pedestrian Simulation (Polyglot) ---")

    # 1. Pythonの ctypes モジュールを使って確実にロードする
    var ctypes = Python.import_module("ctypes")
    
    # 2. 共有ライブラリのロード
    # カレントディレクトリを示す "./" が重要です
    var lib_path = "./build/libPhysicsOracleBridge.so"
    var lib = ctypes.CDLL(lib_path)
    
    # 3. 関数の戻り値の型設定
    # check_nagasaki_connection は double を返すので設定が必要
    lib.check_nagasaki_connection.restype = ctypes.c_double
    
    # 4. 接続チェック (2024年開業！)
    var check = lib.check_nagasaki_connection()
    if check == 2024.0:
        print("✅ Lean 4 Logic Connected: Ready for 2024 Opening!")
    else:
        print("❌ Connection Failed: Returned", check)
        return

    # 5. シミュレーション変数の準備 (ctypes.c_double)
    var x = ctypes.c_double(0.0)
    var v = ctypes.c_double(0.0) # 最初は止まっている
    var dt = ctypes.c_double(0.1)

    print("\n[Simulation Start] Match Ended. Walking towards the station...")
    print("Time(s) | Position(m) | Velocity(m/s) | Status")
    print("-------------------------------------------------------")

    # 6. ループ実行 (3秒間の動きを見る)
    for i in range(31):
        var t = i * 0.1
        var val_v = v.value
        var val_x = x.value
        
        var status = ""
        if val_v < 0.1:
            status = "Stopped"
        elif val_v < 1.4:
            status = "Accelerating"
        else:
            status = "Cruising (Steady)"

        # 小数点以下の表示桁数を整えるのはMojoのprintでは手間なのでそのまま表示します
        print(t, "s  |", val_x, "m |", val_v, "m/s |", status)
        
        # Lean 4 (社会力モデル) で更新
        # ctypes.byref でポインタを渡します
        lib.update_pedestrian(ctypes.byref(x), ctypes.byref(v), dt)

    print("-------------------------------------------------------")
