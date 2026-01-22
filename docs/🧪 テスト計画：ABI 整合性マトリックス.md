おっしゃる通りです。「とりあえず動かす」ための回避策（UInt8化）ではなく、**「なぜ Float が通らないのか（または、どの条件下なら通るのか）」** を切り分けるための、エンジニアリングとして誠実な **「境界値分析・ABI探査テスト」** を行いましょう。

これは、Mojo と Lean 4 の間の「ブラックボックス」になっている通信部分を、外科手術のように切り分けるプロセスです。

以下の **4つのレベル** のテスト関数を実装し、どこでデータが壊れるかを特定します。

### 🧪 テスト計画：ABI 整合性マトリックス

| Level | テスト名 | 検証内容 | 期待される動作 | 失敗時の推測原因 |
| --- | --- | --- | --- | --- |
| **L1** | `probe_u8_baseline` | **整数の疎通** | `1` が返る | リンク自体が失敗している |
| **L2** | `probe_float_const` | **Float戻り値** | `123.456` が返る | 戻り値レジスタ(XMM0 vs RAX)の不一致 |
| **L3** | `probe_float_identity` | **Float引数1つ** | 入力 `x` がそのまま返る | 引数レジスタのズレ、または32/64bit不一致 |
| **L4** | `probe_float_add` | **Float引数2つ** | `a + b` が返る | 複数引数のスタック/レジスタ配置ミス |

---

### 1. `src/SimpleOracle.lean` (テストプローブ実装)

既存のロジックは一旦コメントアウトするか無視し、以下の **ABI探査用関数** を末尾に追記（または全書き換え）してください。

```lean
import SciLean

-- ==========================================
-- TDD: ABI Probing Module
-- Mojo <-> Lean 4 FFI Boundary Test
-- ==========================================

-- [L1] Baseline: Integer Return
-- これが通らなければ、そもそも関数呼び出しができていない
@[export probe_u8_baseline]
def probe_u8_baseline (_ : Unit) : UInt8 := 
  1

-- [L2] Return Register Test
-- 引数なしで Float を返す。
-- Lean が XMM0 レジスタに値を入れているか確認する。
@[export probe_float_const]
def probe_float_const (_ : Unit) : Float := 
  123.456

-- [L3] Argument Register Test (Single)
-- 受け取った値をそのまま返す（エコーバック）。
-- Mojo が渡した値が、Lean 側で正しく読めているか確認する。
@[export probe_float_identity]
def probe_float_identity (x : Float) : Float := 
  x

-- [L4] Argument Alignment Test (Double)
-- 2つの引数を足して返す。
-- 第2引数がズレていないか（アライメント問題）を確認する。
@[export probe_float_add]
def probe_float_add (a b : Float) : Float := 
  a + b

```

---

### 2. `mojo/abi_probe.mojo` (テストランナー)

このスクリプトは、上記4つの関数を順番に呼び出し、**「どこまで成功し、どこから失敗するか」** の証拠ログを出力します。

```mojo
from memory import UnsafePointer, alloc
from python import Python

fn main() raises:
    print("================================================================")
    print("   🕵️ AQUATONES-ALETHEIA: ABI Condition Coverage Probe")
    print("================================================================")
    
    var ffi = Python.import_module("ctypes")
    var os = Python.import_module("os")
    var lib_path = String(os.getcwd()) + "/build/libPhysicsOracleBridge.so"
    var lib = ffi.CDLL(lib_path)

    # ---------------------------------------------------------
    # Test L1: UInt8 Baseline
    # ---------------------------------------------------------
    lib.probe_u8_baseline.argtypes = []
    lib.probe_u8_baseline.restype = ffi.c_uint8
    
    var l1_res = Int(lib.probe_u8_baseline())
    var l1_pass = (l1_res == 1)
    
    print("[L1] UInt8 Baseline       | Expected: 1       | Actual: " + String(l1_res) + " | " + ("✅ PASS" if l1_pass else "❌ FAIL"))

    # ---------------------------------------------------------
    # Test L2: Float Constant (Return Value Check)
    # ---------------------------------------------------------
    lib.probe_float_const.argtypes = []
    lib.probe_float_const.restype = ffi.c_double  # Lean Float is usually 64-bit double

    var l2_py = lib.probe_float_const()
    var l2_res = Float64(l2_py)
    var l2_expected = 123.456
    var l2_pass = abs(l2_res - l2_expected) < 0.001

    print("[L2] Float Constant       | Expected: 123.456 | Actual: " + String(l2_res) + " | " + ("✅ PASS" if l2_pass else "❌ FAIL"))

    # ---------------------------------------------------------
    # Test L3: Float Identity (Argument Read Check)
    # ---------------------------------------------------------
    lib.probe_float_identity.argtypes = [ffi.c_double]
    lib.probe_float_identity.restype = ffi.c_double

    var l3_input = 99.99
    var l3_py = lib.probe_float_identity(ffi.c_double(l3_input))
    var l3_res = Float64(l3_py)
    var l3_pass = abs(l3_res - l3_input) < 0.001

    print("[L3] Float Identity (x=x) | Expected: " + String(l3_input) + "   | Actual: " + String(l3_res) + " | " + ("✅ PASS" if l3_pass else "❌ FAIL"))

    # ---------------------------------------------------------
    # Test L4: Float Add (Multi-Arg Alignment Check)
    # ---------------------------------------------------------
    lib.probe_float_add.argtypes = [ffi.c_double, ffi.c_double]
    lib.probe_float_add.restype = ffi.c_double

    var l4_a = 10.0
    var l4_b = 20.0
    var l4_py = lib.probe_float_add(ffi.c_double(l4_a), ffi.c_double(l4_b))
    var l4_res = Float64(l4_py)
    var l4_pass = abs(l4_res - 30.0) < 0.001

    print("[L4] Float Add (a+b)      | Expected: 30.0    | Actual: " + String(l4_res) + "  | " + ("✅ PASS" if l4_pass else "❌ FAIL"))

    print("================================================================")
    if not l2_pass:
        print("🔍 DIAGNOSIS: Return type mismatch.")
        print("   Try changing Mojo side to ffi.c_float (32-bit) to check width.")
    if l2_pass and not l3_pass:
        print("🔍 DIAGNOSIS: Argument passing mismatch.")
        print("   Mojo is sending Double, Lean might be expecting boxed object.")

```

---

### 3. ビルドと実行

キャッシュが残っていると前の結果が返ってくるので、**徹底的に消してから**実行します。

```bash
# 1. クリーンアップ
rm -rf .lake/build/ir
rm build/libPhysicsOracleBridge.so

# 2. Leanビルド
CPATH="$PIXI_PROJECT_ROOT/.pixi/envs/default/include" \
LIBRARY_PATH="$PIXI_PROJECT_ROOT/.pixi/envs/default/lib" \
LD_LIBRARY_PATH="$PIXI_PROJECT_ROOT/.pixi/envs/default/lib:$LD_LIBRARY_PATH" \
lake build PhysicsOracle

# 3. ブリッジビルド
pixi run build-bridge

# 4. TDD Probe 実行
LD_PRELOAD="$LIB_RUNTIME:$LIB_INIT:$ALL_PACKAGE_SO" mojo mojo/abi_probe.mojo

```

### 何を見るべきか？

この結果のログ（表）を教えてください。
もし **[L2] が ❌ FAIL** するなら、Mojoの `c_double` と Leanの `Float` のビット幅が違います。
もし **[L2] は ✅ PASS だが [L3] が ❌ FAIL** するなら、値の「渡し方」に問題があります。

さあ、白黒つけましょう。結果をお待ちしています。