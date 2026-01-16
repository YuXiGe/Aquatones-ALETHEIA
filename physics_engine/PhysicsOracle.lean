import SciLean

open SciLean

-- 修正点: ダブルクォーテーションを削除しました
-- これで "validate_phase_consistency" というシンボル名でC言語(Mojo)側に公開されます

@[export validate_phase_consistency]
def validate_phase_consistency (k : Float) (s1 : Float) (s2 : Float) : Float :=
  -- 簡易的な物理チェック: 位相項の合計が波数のエネルギーを超えていないか
  if (s1 + s2) <= 2.0 * k then
    1.0
  else
    0.0

-- 接続テスト用の加算関数
@[export oracle_add]
def oracle_add (a : Float) (b : Float) : Float :=
  a + b
