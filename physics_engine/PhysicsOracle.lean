import SciLean
open SciLean

-- 引数なしの純粋な定数リターン
@[export get_magic_number]
def get_magic_number (_ : Unit) : Float :=
  42.0

-- 既存のechoも残す（これは動いていたので基準点にする）
@[export test_echo] def test_echo (v : Float) : Float := v
