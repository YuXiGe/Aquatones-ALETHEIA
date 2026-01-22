**ずっこし！おめでとうございます！**
ついに、ついにやりましたね！画面に流れる `Position (q)` と `Momentum (p)` の数値の変化、その美しい調和振動の軌跡こそが、長いデバッグの旅の勝利の証です。

Mathlib や SciLean という「巨艦」を抱えた Lean 4 を、C++ の世界に引きずり込み、完全に制御下に置きました。これは単なるビルド成功ではなく、**「Lean 4 を高性能な物理演算カーネルとして既存システムに組み込む」ための確立された技術**です。

この貴重な知見を失わないよう、未来のあなた（そして世界中の Lean ユーザー）のために、**「Lean 4 + SciLean + C++ 統合・完全攻略ガイド」**としてドキュメント化しました。

---

# 📘 Lean 4 + SciLean + C++ 統合・完全攻略ガイド

**The "Hybrid-Surgical" Build Method**

## 1. プロジェクトの概要と課題

このプロジェクトの目的は、Lean 4 (SciLean, Mathlib) で記述された物理法則を、C++ (および将来的に Mojo) から呼び出してシミュレーションを行うことです。

### 乗り越えた壁

1. **巨大な依存関係**: Mathlib は大きすぎて C ソースからの全ビルドは不可能。
2. **シンボルの欠落**: 共有ライブラリ (`libLeanBLAS.so`) だけでは、特定のボックス化関数 (`___boxed`) が不足する。
3. **複雑なランタイムリンク**: 実行時に Lean コアや Mathlib が正しくロードされないと `symbol lookup error` で落ちる。

---

## 2. 戦略：「ハイブリッド・サージカル・ビルド」

この問題を解決するために確立したのが、以下のハイブリッド戦略です。

1. **重いライブラリ (Mathlib, SciLean)**:
* **共有ライブラリ (.so)** として扱い、リンクするだけにする。ソースコンパイルはしない。


2. **軽いライブラリ (LeanBLAS) の不足分**:
* 不足しているシンボルを含む `.c` ソース (例: `FFI/FloatArray.c`) を特定し、CMake で**外科的に (Surgically) 直接コンパイル**してバイナリに混ぜる。


3. **実行時の全ロード (Total Recall)**:
* `LD_PRELOAD` を使い、関連する全ての `.so` をメモリに強制展開して依存関係を解決する。



---

## 3. 実装コード (Gold Standard)

### A. Lean 側 (`SimpleOracle.lean`)

物理法則を記述します。エクスポートする関数は `@[export]` を付け、`Float` 型を使用します。

```lean
import SciLean
open SciLean

-- 物理定数
def m : Float := 1.0
def k : Float := 1.0

-- 解析解による力の計算 (F = -kq)
-- 自動微分を使う場合は SciLean.deriv 等を利用
@[export get_force]
def get_force (q : Float) : Float :=
  -1.0 * k * q

-- 状態更新 (シンプレクティック・オイラー法等の基礎)
@[export get_next_position]
def get_next_position (q p dt : Float) : Float :=
  q + (p / m) * dt

@[export get_next_momentum]
def get_next_momentum (q p dt : Float) : Float :=
  p + (get_force q) * dt

-- 疎通確認用 (重要)
@[export lean_test_function]
def lean_test_function (_ : Unit) : Float := 1.0

```

### B. CMake ビルド設定 (`CMakeLists.txt`)

これがこのビルドの心臓部です。**ソースの注入**と**ライブラリのリンク**を同時に行います。

```cmake
cmake_minimum_required(VERSION 3.20)
project(PhysicsOracleBridge LANGUAGES CXX C)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# 1. パス設定 (環境に合わせて変更)
set(LEAN_ROOT "$ENV{HOME}/.elan/toolchains/leanprover--lean4---v4.20.1")
include_directories("src" "${LEAN_ROOT}/include")

# 2. ソースコードの選別 (ここが重要！)
# メインの Lean コード
set(MAIN_SRC "${CMAKE_CURRENT_SOURCE_DIR}/.lake/build/ir/SimpleOracle.c")

# [外科手術] LeanBLAS の不足シンボルを補うために FFI ソースを直接コンパイル
file(GLOB LEANBLAS_FFI_SRCS "${CMAKE_CURRENT_SOURCE_DIR}/.lake/packages/leanblas/.lake/build/ir/LeanBLAS/FFI/*.c")
# Glue コード (C実装) も注入
file(GLOB_RECURSE LEANBLAS_GLUE_OBJS "${CMAKE_CURRENT_SOURCE_DIR}/.lake/packages/leanblas/.lake/build/c/*.o")
file(GLOB_RECURSE SCILEAN_GLUE_OBJS  "${CMAKE_CURRENT_SOURCE_DIR}/.lake/packages/scilean/.lake/build/c/*.o")

# 3. 共有ライブラリの収集
set(LAKE_LIB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/.lake/packages")
set(CANDIDATE_LIBS
    "${LAKE_LIB_DIR}/scilean/.lake/build/lib/libSciLean.so"
    "${LAKE_LIB_DIR}/mathlib/.lake/build/lib/libMathlib.so"
    "${LAKE_LIB_DIR}/aesop/.lake/build/lib/libAesop.so"
    "${LAKE_LIB_DIR}/leanblas/.lake/build/lib/libLeanBLAS.so"
    "${LAKE_LIB_DIR}/batteries/.lake/build/lib/libBatteries.so"
)
# 存在するライブラリだけをリンク対象にする
set(EXISTS_LIBS "")
foreach(lib ${CANDIDATE_LIBS})
    if(EXISTS ${lib})
        list(APPEND EXISTS_LIBS ${lib})
    endif()
endforeach()

# 4. ターゲット定義
add_executable(physics_test 
    src/main.cpp src/bridge.cpp
    ${MAIN_SRC} ${LEANBLAS_FFI_SRCS} ${LEANBLAS_GLUE_OBJS} ${SCILEAN_GLUE_OBJS}
)

# 重複定義を許容してリンク
target_link_libraries(physics_test PRIVATE 
    ${EXISTS_LIBS} 
    "${LEAN_ROOT}/lib/lean/libLake_shared.so"
    leanshared openblas pthread dl m
)
target_link_options(physics_test PRIVATE "-Wl,--allow-multiple-definition" "-Wl,--export-dynamic")

```

### C. C++ ブリッジ (`src/bridge.cpp`)

Lean ランタイムの初期化と、ABI (型) の変換を担当します。

```cpp
#include <lean/lean.h>
extern "C" {
    // Lean 側の関数
    double get_next_position(double q, double p, double dt);
    double get_next_momentum(double q, double p, double dt);
    // 初期化関数
    void lean_initialize_runtime_module();
    void lean_initialize();
    lean_object* initialize_SimpleOracle(uint8_t, lean_object*);
}

extern "C" void init_lean_system() {
    static bool initialized = false;
    if (!initialized) {
        lean_initialize_runtime_module();
        lean_initialize();
        initialize_SimpleOracle(1, lean_io_mk_world());
        initialized = true;
    }
}

extern "C" void simulate_oscillator_step(double* q, double* p, double dt) {
    init_lean_system();
    double nq = get_next_position(*q, *p, dt);
    double np = get_next_momentum(*q, *p, dt);
    *q = nq; *p = np;
}

```

---

## 4. ビルドと実行の手順 (魔法のコマンド)

最後に、実行時に全ての依存関係を解決するコマンドです。これをシェルスクリプト (`run.sh` 等) に保存しておくと便利です。

```bash
#!/bin/bash

# 1. Lean ビルド
lake build

# 2. C++ ビルド
mkdir -p build && cd build
cmake .. && make -j$(nproc)

# 3. 環境変数の設定 (Total Recall Strategy)
export PRJ_ROOT=$(dirname $(pwd))
export LEAN_TOOLCHAIN_DIR="$HOME/.elan/toolchains/leanprover--lean4---v4.20.1"
export LEAN_LIB_DIR="${LEAN_TOOLCHAIN_DIR}/lib/lean"

# 全ての共有ライブラリ (.so) のパスを探す
export ALL_SO=$(find $PRJ_ROOT/.lake -name "*.so" | tr '\n' ' ')
export LEAN_CORES=$(find $LEAN_LIB_DIR -name "*.so" | tr '\n' ' ')

# LD_LIBRARY_PATH の設定
export LD_LIBRARY_PATH=$LEAN_LIB_DIR:$(find $PRJ_ROOT/.lake -type d -name "lib" | tr '\n' ':'):$LD_LIBRARY_PATH

# 4. 実行 (LD_PRELOAD で全ロード)
echo "🚀 Running Physics Simulation..."
LD_PRELOAD="$LEAN_CORES $ALL_SO" ./physics_test

```

---

## 5. トラブルシューティング集

| エラー内容 | 原因 | 解決策 |
| --- | --- | --- |
| `undefined symbol: ...___boxed` | 共有ライブラリに関数ラッパーが含まれていない | その関数を含む `.c` ファイル (FFIフォルダ等) を CMake で直接コンパイルする。 |
| `initialize_Mathlib... undefined` | ソースコンパイル時に Mathlib の初期化関数が見つからない | ソースコンパイルを諦め、`libMathlib.so` をリンクする。 |
| `symbol lookup error` (実行時) | 依存ライブラリ (Aesop, Std) がロードされていない | `LD_PRELOAD` に全ての `.so` を列挙して強制ロードする。 |
| 値が `0` になる / `Segmentation Fault` | 引数の型や数が合っていない | Lean の `Float` は C の `double`。引数がない場合は `lean_box(0)` (Unit) を渡す。 |
| `unexpected token '@['` | Lean コードの文法エラー | 関数定義の前に必ずアトリビュートを書く。インデントに注意する。 |

---

### 🎉 Future Work: Mojo への道

この `libPhysicsOracleBridge.so` (共有ライブラリ版) は、すでに Mojo からロード可能な状態です。
Mojo の `DLHandle` を使い、上記の `LD_PRELOAD` 環境下で実行すれば、Python 以上の速度で Lean の物理エンジンを回すことができます。

これで、いつでもこの環境を再現できますね。本当にお疲れ様でした！