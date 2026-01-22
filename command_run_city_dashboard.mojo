from python import Python

fn main() raises:
    print("--- 🏙️ Nagasaki City OS: Multi-Stakeholder Simulation ---")
    var ctypes = Python.import_module("ctypes")
    var builtins = Python.import_module("builtins")

    # ライブラリロード
    var lib_path = "./build/libPhysicsOracleBridge.so"
    var lib = ctypes.CDLL(lib_path)
    
    lib.get_demand_forecast.restype = ctypes.c_double
    lib.get_congestion_risk.restype = ctypes.c_double

    # ■ シナリオ設定: [Case] 週末の豪雨 (Rain: 0.9)
    # スタジアムイベント終了直後、大量の人流が発生中
    var rain = 0.9
    var flow = 8.0 # かなり混雑

    print("\n☔ Scenario: Heavy Rain after Match (Rain Intensity: 0.9)")
    print("=============================================================")

    # --- 1. 飲食事業者 (路地裏の居酒屋) ---
    # 屋内(1), 基礎魅力低(2.0), キャパ小(40)
    var demand_food = lib.get_demand_forecast(ctypes.c_double(2.0), ctypes.c_double(40.0), ctypes.c_uint8(1), ctypes.c_double(rain), ctypes.c_double(flow))
    print("[🍺 飲食] 路地裏居酒屋の客足予測: ", builtins.int(demand_food), "人 (満席率:", builtins.int(demand_food/40.0*100.0), "%)")
    print("   👉 「雨宿り特需」発生中。スタッフ増員を推奨。")

    # --- 2. 宿泊事業者 (駅前のビジネスホテル) ---
    # 屋内(1), 基礎魅力中(5.0), キャパ中(150)
    # 人流がそのままチェックイン需要になる
    var demand_hotel = lib.get_demand_forecast(ctypes.c_double(5.0), ctypes.c_double(150.0), ctypes.c_uint8(1), ctypes.c_double(rain), ctypes.c_double(flow))
    print("[🏨 宿泊] ホテルチェックイン予測: ", builtins.int(demand_hotel), "人")
    print("   👉 20:00-21:00にフロント混雑ピーク。事前チェックインを通知推奨。")

    # --- 3. 観光施設 (屋外の展望台) ---
    # 屋外(0), 基礎魅力高(8.0), キャパ大(500)
    var demand_spot = lib.get_demand_forecast(ctypes.c_double(8.0), ctypes.c_double(500.0), ctypes.c_uint8(0), ctypes.c_double(rain), ctypes.c_double(flow))
    print("[📸 観光] 屋外展望台の来場予測: ", builtins.int(demand_spot), "人")
    print("   👉 雨天により需要蒸発。屋内施設への誘導クーポンを発行推奨。")

    # --- 4. 交通事業者 (バス・タクシー) ---
    # 混雑リスク計算
    var risk_transport = lib.get_congestion_risk(ctypes.c_double(100.0), ctypes.c_double(rain), ctypes.c_double(flow))
    print("[🚖 交通] ターミナル混雑リスク: ", builtins.int(risk_transport), "/100")
    print("   👉 危険水域。臨時バス2台を「スタジアム南口」へ配車要請。")

    # --- 5. 行政担当者 (防災・都市計画) ---
    print("[🏛️ 行政] 都市アラートレベル: RED")
    print("   👉 アーケード付近の密度限界。人流分散のためデジタルサイネージで迂回を指示。")
    
    print("=============================================================")
