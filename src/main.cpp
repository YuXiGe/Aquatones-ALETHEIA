#include <iostream>
#include "bridge.cpp" // 簡易化のため直接includeまたはヘッダーを作成

int main() {
    std::cout << "--- 🚀 C++/Lean Integration Test ---" << std::endl;
    
    // Leanランタイムの初期化 (C++側で管理)
    lean_initialize();
    
    // ブリッジ経由で計算を実行
    double thrust = 1500.0;
    double g = 9.8;
    double result = call_physics_verified(thrust, g);
    
    std::cout << "Result from Lean: " << result << std::endl;
    return 0;
}
