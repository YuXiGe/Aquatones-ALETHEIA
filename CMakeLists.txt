cmake_minimum_required(VERSION 3.20)
project(PhysicsOracleBridge LANGUAGES CXX C)

# 1. コンパイラ設定
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# 2. パス設定 (Pixi環境とElan環境)
set(PIXI_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/.pixi/envs/default")
# Elan のパスは環境に合わせて調整してください
set(LEAN_ROOT "$ENV{HOME}/.elan/toolchains/leanprover--lean4---v4.20.1")

# 3. インクルードディレクトリ
include_directories(
    "${PIXI_ROOT}/include"
    "${LEAN_ROOT}/include"
    "${CMAKE_CURRENT_SOURCE_DIR}/src"
)

# 4. リンクディレクトリ
link_directories(
    "${PIXI_ROOT}/lib"
    "${LEAN_ROOT}/lib/lean"
)

# 5. Leanが生成したオブジェクトファイルを特定
# Leanビルド後に生成される .o ファイルを直接指定します
set(LEAN_OBJ "${CMAKE_CURRENT_SOURCE_DIR}/.lake/build/ir/SimpleOracle.c.o")

# 6. ターゲット: 実行ファイル
add_executable(physics_test 
    src/main.cpp 
    src/bridge.cpp
    ${LEAN_OBJ}
)

# 7. 依存ライブラリのリンク
# leanshared: Leanランタイム
# openblas: SciLeanの計算用
target_link_libraries(physics_test
    leanshared
    openblas
    pthread
    dl
)

# 8. 共有ライブラリ (.so) も生成 (将来的にMojoから呼ぶ用)
add_library(PhysicsOracleBridge SHARED
    src/bridge.cpp
    ${LEAN_OBJ}
)
target_link_libraries(PhysicsOracleBridge
    leanshared
    openblas
)
