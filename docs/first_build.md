ついに**ビルド成功、おめでとうございます！** `ldd` の結果を見ても、Lean ツールチェーン、SciLean、LeanBLAS、そして Pixi 環境の OpenBLAS が一分の隙もなくリンクされており、完璧な実行環境が整いました。

この歴史的なビルドプロセス（14,235ファイルの金字塔）を、将来の自分やチームが再現できるよう、技術ドキュメントとしてまとめました。

---

# 📝 技術仕様書：Aquatones-ALETHEIA 監査エンジン統合

## 1. プロジェクト概要

本プロジェクトは、**Lean 4 (SciLean)** による形式証明に基づいた物理監査ロジックを、**Mojo / C++** の高並密計算環境へ統合するハイブリッド・アーキテクチャの構築を目的とする。

## 2. システム構成

* **論理・監査層**: Lean 4 (SciLean) - 物理法則の形式化と自動微分
* **ブリッジ層**: C++ (Shared Library) - ランタイム初期化および TLS 管理
* **実行層**: Mojo / CUDA (sm_90) - H100 アーキテクチャに最適化された高速演算
* **環境管理**: Pixi (Conda-based) - BLAS, GCC, Python 依存関係の統一

## 3. ビルド・プロセス記録

### ステップ1：環境の初期化と依存関係の同期

Pixi を使用して、Lean 4, SciLean, Mathlib4 を含む 14,000 以上のファイル群を同期。

```bash
pixi run build-lean

```

* **重要**: `LD_LIBRARY_PATH` に Lean ツールチェーンの `/lib/lean` と Pixi の `/lib` を含めることで、ビルド中のプラグインロードエラー（Code 134）を回避。

### ステップ2：Lean オブジェクトファイルの生成

`lake build` により Lean ソースを C コードへ変換。その後、GCC を用いて再配置可能なオブジェクトファイルを生成。

* **成果物**: `.lake/build/ir/SimpleOracle.o`

### ステップ3：C++ ブリッジの構築 (CMake)

Lean の共有ライブラリ (`libleanshared.so`, `libSciLean.so`, `libLeanBLAS.so`) を C++ コードとリンク。

* **主要なリンク先**:
* `leanshared`: Lean 実行ランタイム
* `SciLean`: 自動微分・物理演算ライブラリ
* `openblas`: Pixi 提供の高速行列計算ライブラリ



## 4. 実行時設定 (Runtime Environment)

バイナリを実行する際は、以下のパス設定が不可欠である。

```bash
export LEAN_LIB_PATH=$HOME/.elan/toolchains/leanprover--lean4---v4.20.1/lib/lean
export LD_LIBRARY_PATH=$LEAN_LIB_PATH:$PIXI_PROJECT_ROOT/.pixi/envs/default/lib:$LD_LIBRARY_PATH

```

## 5. 現在の状態と成果物

* **`build/physics_test`**: C++ から Lean ロジックを直接呼び出すテスト実行ファイル。
* **`build/libPhysicsOracleBridge.so`**: Mojo から `dlopen` でロード可能な統合共有ライブラリ。
* **検証済みリンク**: 全ての動的ライブラリが `ldd` により正常に解決されている。

---

### 🚀 次のステップ：実行テスト

ドキュメントが整理されたところで、いよいよ**「魂の起動」**を確認しましょう。

```bash
# 1. 実行パスの最終確認
export LEAN_LIB_PATH=$HOME/.elan/toolchains/leanprover--lean4---v4.20.1/lib/lean
export LD_LIBRARY_PATH=$LEAN_LIB_PATH:$(pwd)/.pixi/envs/default/lib:$(pwd)/build

# 2. テストバイナリの実行
./build/physics_test

```

**「Verified Result: 1.0」と表示されるか、ぜひ確認してください！**
成功を確認でき次第、Mojo 側からこの `.so` を呼び出す最終工程（`flight_audit.mojo`）を完成させましょうか？