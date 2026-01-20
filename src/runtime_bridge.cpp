#include <iostream>
#include <lean/lean.h>
#include <pthread.h>

// Lean 側の計算関数の型
typedef double (*lean_calc_fn)(double, double);

class RuntimeBridge {
private:
    void* lean_tls_storage; // Lean 用の TLS 退避領域
    lean_calc_fn target_fn;

public:
    RuntimeBridge() {
        // 1. Lean ランタイムの初期化
        // Mojo のメインスレッドに干渉しないよう、慎重に呼び出す
        lean_initialize();
        std::cout << "✅ Lean Runtime Initialized inside Bridge" << std::endl;
    }

    // Mojo から呼ばれるエントリポイント
    double safe_execute_lean(double thrust, double g) {
        // 2. TLS の整合性チェック
        // 必要に応じてここで pthread_getspecific 等を用いて TLS を切り替える
        
        // 3. Lean 関数の実行
        // Lean の関数は C 互換の double を受け取り double を返す
        return validate_physics(thrust, g);
    }
};

// C-Linkage で Mojo から呼び出せるようにする
extern "C" {
    RuntimeBridge* create_bridge() { return new RuntimeBridge(); }
    
    double call_physics_verified(RuntimeBridge* bridge, double thrust, double g) {
        return bridge->safe_execute_lean(thrust, g);
    }
}
