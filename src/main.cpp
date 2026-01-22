#include <iostream>
#include <iomanip>

// bridge.cpp で定義した新しい関数群を宣言
extern "C" double check_nagasaki_connection();
extern "C" void update_pedestrian(double* x, double* v, double dt);

int main() {
    std::cout << "--- 🏟️ Nagasaki Stadium City: C++ Sanity Check ---" << std::endl;

    // 1. 接続確認
    double check = check_nagasaki_connection();
    if (check == 2024.0) {
        std::cout << "✅ Lean Logic Connected: Ready for 2024 Opening!" << std::endl;
    } else {
        std::cout << "❌ Connection Failed: Returned " << check << std::endl;
        return 1;
    }

    // 2. 歩行者シミュレーション (簡易版)
    double x = 0.0;
    double v = 0.0;
    double dt = 0.1;

    std::cout << "\n[C++ Test] Walking Simulation (First 5 steps)..." << std::endl;
    std::cout << "Time(s) | Pos(m) | Vel(m/s)" << std::endl;
    std::cout << "---------------------------" << std::endl;

    for (int i = 0; i < 5; ++i) {
        std::cout << std::fixed << std::setprecision(4);
        std::cout << (i * dt) << "    | " << x << " | " << v << std::endl;
        
        // 更新
        update_pedestrian(&x, &v, dt);
    }

    return 0;
}
