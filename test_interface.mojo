from python import Python

def main():
    try:
        var ctypes = Python.import_module("ctypes")
        var lib = ctypes.CDLL("./libPhysicsOracle.so")
        lib.initialize_SimpleOracle(0, None)

        # 6引数プロトタイプ定義
        lib.validate_physics.argtypes = [
            ctypes.c_double, ctypes.c_double, ctypes.c_double,
            ctypes.c_double, ctypes.c_double, ctypes.c_double
        ]
        lib.validate_physics.restype = ctypes.c_double

        print("--- ✈️ B-21 ALETHEIA ADVANCED AUDIT ---")

        # 判定用ヘルパー関数（インライン）
        def run_audit(name: String, k: Float64, s1: Float64, s2: Float64, alpha: Float64, thrust: Float64, g: Float64):
            var res = Float64(lib.validate_physics(k, s1, s2, alpha, thrust, g))
            var status: String = ""
            if res == 1.0: status = "✅ OK"
            elif res == 0.0: status = "❌ STRUCTURAL FAILURE"
            elif res == 2.0: status = "⚠️ STALL WARNING"
            elif res == 3.0: status = "📡 STEALTH COMPROMISED"
            else: status = "❓ UNKNOWN"
            print("Scenario:", name, "-> Result:", status)

        # 各シナリオの実行
        run_audit("NORMAL_CRUISE",     200.0, 100.0, 50.0, 5.0,  80.0, 1.0)
        run_audit("STRUCTURAL_DANGER", 100.0, 100.0, 80.0, 5.0,  80.0, 1.0)
        run_audit("STALL_RISK",        200.0, 100.0, 50.0, 25.0, 30.0, 1.2)
        run_audit("STEALTH_LOSS",      200.0, 100.0, 50.0, 10.0, 90.0, 5.5)

        print("--- Audit Complete ---")

    except e:
        print("❌ Runtime Error:", e)
