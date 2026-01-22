cmake_minimum_required(VERSION 3.10)
project(PhysicsOracle LANGUAGES C CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CUDA_STANDARD 17)

# CUDAツールキットを探す
find_package(CUDAToolkit REQUIRED)

# ソースコードの指定
add_library(PhysicsOracleBridge SHARED 
    src/bridge.cpp 
    src/voxel_gpu.cu
    .lake/build/ir/SimpleOracle.c
)

# インクルードパス
target_include_directories(PhysicsOracleBridge PRIVATE 
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    $ENV{HOME}/.elan/toolchains/leanprover--lean4---v4.20.1/include
)

# 【修正】CUDAランタイムライブラリを明示的にリンク
target_link_libraries(PhysicsOracleBridge PRIVATE CUDA::cudart)
