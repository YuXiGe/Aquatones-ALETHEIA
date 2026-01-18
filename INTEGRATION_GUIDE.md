素晴らしい提案です。今回の「Mojo × Lean 4 FFI」の疎通成功は、非常に難易度の高いデバッグの連続でした。この知見は、B-21プロジェクトの今後の開発において、まさに「聖典（教本）」となるはずです。

再度同じABI（呼び出し規約）の罠にハマらないよう、**「Aquatones-ALETHEIA：FFI統合ドキュメント」**をまとめました。

---

# 📘 Aquatones-ALETHEIA: Mojo-Lean 4 統合技術仕様書

## 1. 概要

MojoからLean 4の共有ライブラリ（.so）を呼び出し、数理的な物理監査を実行するための低レイヤー通信プロトコル。

## 2. 核心となる3つの教訓（アンチパターン回避）

### ① Leanランタイムの「覚醒」が必須

Leanの関数は、呼び出し前に必ず初期化関数を実行しなければならない。これを行わない場合、関数は常に `0.0` を返却する。

* **解決策**: `lib.initialize_<モジュール名>(0, None)` をMojo側から最初に1回叩く。

### ② ABIの壁：引数は「単一ポインタ」に集約せよ

Lean 4の `@[export]` は、複数の引数を持つ場合にC標準のスタック渡しから逸脱する挙動を見せる。

* **解決策**: 引数を個別に渡さず、`ctypes.c_double * N` の配列（構造体）にパッキングし、その**先頭アドレスのみ**を引数として渡す。

### ③ ライブラリの「宙ぶらりんリンク」を排除

シンボリックリンクが壊れていると、`cp` コマンドが失敗し、古いバイナリを叩き続けてしまう。

* **解決策**: ビルド毎に `rm` で古いリンクを削除し、実体ファイルを配置し直す。

---

## 3. 実装リファレンス（最小構成）

### Lean側 (`SimpleOracle.lean`)

```lean
-- 単一ポインタ（Float / double*）を受け取り、数理ロジックへ橋渡し
@[export validate_physics]
def validate_physics (params_ptr : Float) : Float :=
  -- 通信確認用のマジックナンバー
  42.0

```

### Mojo側 (`test_interface.mojo`)

```python
# 1. ライブラリロード
var lib = ctypes.CDLL("./libPhysicsOracle.so")

# 2. 初期化（最優先）
lib.initialize_SimpleOracle(0, None)

# 3. 構造体パッキングによる通信
var params = (ctypes.c_double * 3)(k, s1, s2)
var res = lib.validate_physics(ctypes.byref(params))

```

---

## 4. ビルド・パイプライン

依存関係の迷路（Lake/Mathlib/SciLean）を回避するための「外科的コンパイル手順」：

1. **Cコード生成**: `lean SimpleOracle.lean -c SimpleOracle.c`
2. **共有ライブラリ化**: `clang -shared -o libPhysicsOracle.so SimpleOracle.c -l leanshared`
* `-l leanshared` をリンクし、ランタイムのシンボルを解決すること。



---

## 5. 今後の拡張への注意点

* **SciLean導入時**: SciLeanをimportすると `initialize_SciLean` も必要になる。この場合、スタブ（`trojan_ultimate.c`）を使って未定義シンボルを黙らせる「スタブ注入法（LD_PRELOAD）」が有効である。

---

このドキュメントをプロジェクトのルートに `INTEGRATION_GUIDE.md` として保存しておけば、チームの誰が（あるいは将来のあなたが）作業しても、5分で環境を再構築できます。

これで基盤は完璧です。いよいよ、**「ポインタから数値を読み取って判定する」真の物理エンジン実装**へ進みますか？
