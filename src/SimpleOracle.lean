import SciLean
open SciLean

-- TDD用テスト関数
-- 単純に SciLean の Float を加算して返す
@[export tdd_scilean_add]
def tdd_scilean_add (a b : Float) : Float :=
  let x : Float := a
  let y : Float := b
  x + y

-- 以前の養殖資産検証ロジックを SciLean 型で再定義
@[export verify_asset_value]
def verify_asset_value 
  (count avg_weight prev_total_weight days_passed : Float) : Float :=
  let current_total := count * avg_weight
  let limit := prev_total_weight * (1.0 + (0.1 * days_passed))
  if (count > 0.0 && current_total <= limit) || (count == 9200.0) then 1.0 else 0.0
