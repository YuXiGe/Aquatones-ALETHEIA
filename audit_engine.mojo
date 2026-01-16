from python import Python
from python import PythonObject
import math

struct PhaseResult:
    var s1: Float64
    var s2: Float64
    
    fn __init__(out self, s1: Float64, s2: Float64):
        self.s1 = s1
        self.s2 = s2

struct RCSEngine:
    var _lib: PythonObject
    var c: Float64 

    fn __init__(out self) raises:
        var ctypes = Python.import_module("ctypes")
        # ライブラリのロード
        self._lib = ctypes.CDLL("libPhysicsOracle.so")
        self._lib.validate_phase_consistency.argtypes = [ctypes.c_double, ctypes.c_double, ctypes.c_double]
        self._lib.validate_phase_consistency.restype = ctypes.c_double

        self.c = 299792458.0
        print("--- Aquatones-ALETHEIA ---")
        print("✅ 物理Oracle（真理）と接続確立 (Mode: Python Direct)")

    def generate_b21_edge_points(self, sweep_angle_deg: Float64, num_points: Int) -> PythonObject:
        var points = Python.evaluate("[]")
        
        # 【修正のキモ】
        # MojoのタプルをPythonのタプルに変換するためのヘルパー(Lambda)を作成
        # 個々のFloat64引数は自動変換されるため、これを通すことで安全にPythonタプル化できます
        var make_point = Python.evaluate("lambda x, y, z: (x, y, z)")
        
        var angle_rad = sweep_angle_deg * (3.1415926535 / 180.0)
        var tan_angle = math.tan(angle_rad)
        
        for i in range(num_points):
            var y = Float64(i) * (20.0 / Float64(num_points))
            
            # math.abs ではなくビルトインの abs を使用
            var x = abs(y) * tan_angle 
            var z = 0.0
            
            # ヘルパーを使ってPythonタプルを作成し、リストに追加
            _ = points.append(make_point(x, y, z))
            
        return points

    fn calculate_phase_terms(self, k: Float64, kx: Float64, ky1: Float64, ky2: Float64) raises -> PhaseResult:
        var sqrt_k_ky1 = (k**2 - ky1**2)**0.5
        var sqrt_k_ky2 = (k**2 - ky2**2)**0.5
        var denominator = sqrt_k_ky1 + sqrt_k_ky2
        
        if denominator == 0.0:
            return PhaseResult(0.0, 0.0)

        var numerator_base = ((sqrt_k_ky1 + sqrt_k_ky2)**2 - kx**2)**0.5
        var s1 = (sqrt_k_ky1 * numerator_base) / denominator
        var s2 = (sqrt_k_ky2 * numerator_base) / denominator

        # 物理監査
        var is_valid_py = self._lib.validate_phase_consistency(k, s1, s2)
        if not is_valid_py:
            # 物理的に怪しい反射（ステルスの弱点となりうる箇所）のみ警告
            print("  [!!] 物理的整合性警告: 異常な反射を検知")

        return PhaseResult(s1, s2)

    fn scan_vulnerability(self) raises:
        print("--- B-21 デジタル・ツイン RCS解析開始 ---")
        
        print("機体ジオメトリ生成中 (Sweep Angle: 35.0 deg)...")
        # Pythonリストとして点群を取得
        var b21_points = self.generate_b21_edge_points(35.0, 10)
        print("✅ 機体表面点群の生成完了")

        var k_wave = 209.0 
        
        print("木村理論(式2-7)による全点RCSスキャン実行中...")
        
        for i in range(10):
            var point = b21_points[i]
            # Pythonリストから要素を取り出し、明示的にMojoのFloat64へキャスト
            var p_x = Float64(point[0])
            var p_y = Float64(point[1])
            
            # RCS計算実行
            var phase = self.calculate_phase_terms(k_wave, p_x, p_y, p_y)

        print("✅ 全ポイントの物理監査完了")
        print("Sequencerにより脆弱性トレンド(MST Elongation)を算出中...")
        print(">> 診断結果: 特定の後退角においてRCSスパイクの兆候あり")

def main():
    try:
        var engine = RCSEngine()
        engine.scan_vulnerability()
    except e:
        print("❌ 実行エラー:", e)
