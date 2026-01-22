from python import Python

fn main() raises:
    print("--- 🏟️ Nagasaki Stadium City: NFT Pricing Simulation ---")

    var ctypes = Python.import_module("ctypes")
    # Pythonの標準関数(int, float等)を使うために builtins をインポート
    var builtins = Python.import_module("builtins")

    # パス設定（環境に合わせて修正不要ですが、念のためカレントディレクトリ基準）
    var lib_path = "./build/libPhysicsOracleBridge.so"
    var lib = ctypes.CDLL(lib_path)
    
    # 戻り値の型設定
    lib.get_current_nft_price.restype = ctypes.c_double
    lib.update_pedestrian.restype = ctypes.c_void_p

    var dt = ctypes.c_double(0.1)
    
    var rain_levels = Python.list()
    rain_levels.append(0.0)
    rain_levels.append(0.8)
    
    var weather_names = Python.list()
    weather_names.append("Sunny ☀️")
    weather_names.append("Heavy Rain ☔")

    for scenario_idx in range(2):
        # Pythonオブジェクトのまま扱います（変換不要）
        var rain = rain_levels[scenario_idx]
        var weather = weather_names[scenario_idx]

        print("\n=======================================================")
        print("Scenario:", weather, "(Rain Intensity:", rain, ")")
        print("Time(s) | Velocity(m/s) | Resistance(Ω) | NFT Price(JPY)")
        print("-------------------------------------------------------")
        
        var x = ctypes.c_double(0.0)
        var v = ctypes.c_double(0.0)
        
        for i in range(31):
            var t = i * 0.1
            var val_v = v.value
            
            # 価格計算 (Pythonオブジェクト同士の計算なので安全)
            var price = lib.get_current_nft_price(ctypes.c_double(val_v), ctypes.c_double(rain))
            
            # 抵抗値の計算
            var resistance = 1.0 + 4.0 * rain
            
            # 表示用の整数変換に Python の int() を使用
            var price_int = builtins.int(price)
            
            # MojoのprintはPythonオブジェクトをそのまま表示できます
            print(t, "s  |", val_v, "m/s   |", resistance, "      |", price_int, "JPY")
            
            lib.update_pedestrian(ctypes.byref(x), ctypes.byref(v), dt)

    print("=======================================================")
