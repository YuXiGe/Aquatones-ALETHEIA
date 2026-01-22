#include <cuda_runtime.h>
#include <stdio.h>
#include <math.h>

// [GPU Kernel] 1つのボクセルの計算を担当
// idx: スレッドID（＝ボクセルの座標）
__global__ void diffusion_kernel(float* grid, int size, float decay_rate) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    
    if (idx < size) {
        // 現在の密度を取得
        float val = grid[idx];
        
        // 簡易的な物理演算: 
        // 1. 自然減衰 (decay)
        // 2. ノイズ的な変動 (sin波でシミュレーション)
        float flow = sinf(val * 10.0f + 0.1f) * 0.05f;
        
        // 新しい値を書き込む
        // (本来はダブルバッファリングが必要ですが、デモ用に直接更新)
        grid[idx] = fmaxf(0.0f, val * decay_rate + flow);
    }
}

// [C++ Bridge] Mojoから呼び出すためのホスト関数
extern "C" {

void launch_gpu_simulation(float* host_data, int size) {
    float* dev_data;
    size_t bytes = size * sizeof(float);

    // 1. GPUメモリ確保
    cudaMalloc((void**)&dev_data, bytes);

    // 2. CPU -> GPU データ転送
    cudaMemcpy(dev_data, host_data, bytes, cudaMemcpyHostToDevice);

    // 3. カーネル起動
    // 256スレッド/ブロック でグリッドを分割
    int blockSize = 256;
    int numBlocks = (size + blockSize - 1) / blockSize;
    
    diffusion_kernel<<<numBlocks, blockSize>>>(dev_data, size, 0.99f);
    
    // エラーチェック（同期）
    cudaDeviceSynchronize();

    // 4. GPU -> CPU 結果書き戻し
    cudaMemcpy(host_data, dev_data, bytes, cudaMemcpyDeviceToHost);

    // 5. 解放
    cudaFree(dev_data);
}

}
