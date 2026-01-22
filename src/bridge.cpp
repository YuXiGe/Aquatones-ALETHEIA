#include <lean/lean.h>
#include <iostream>

extern "C" {
    // 既存の関数定義があれば残しますが、ここでは新規分を定義
    // (以前のSocial Force関連も必要なら残すべきですが、今回はデモ用にシンプルにします)
    
    double calculate_demand_forecast(double base_attr, double capacity, uint8_t is_indoor, double rain, double flow);
    double calculate_congestion_risk(double capacity, double rain, double flow);
    double lean_zenrin_check(lean_object*);

    // 初期化関連
    void lean_initialize_runtime_module();
    void lean_initialize();
    lean_object* initialize_ZenrinOracle(uint8_t, lean_object*); // モジュール名注意
    lean_object* initialize_SimpleOracle(uint8_t, lean_object*); // 前回の名残
    void lean_io_mark_end_initialization();
}

// 初期化ラッパー
extern "C" void init_zenrin_system() {
    static bool initialized = false;
    if (!initialized) {
        lean_initialize_runtime_module();
        lean_initialize();
        // 今回はZenrinOracleを使いますが、ビルド構成に合わせてSimpleOracleのままにするか調整
        // ここではファイル名を変えず中身を変えた想定で SimpleOracle を初期化します
        initialize_SimpleOracle(1, lean_io_mk_world());
        lean_io_mark_end_initialization();
        initialized = true;
    }
}

extern "C" double check_zenrin_connection() {
    init_zenrin_system();
    return lean_zenrin_check(lean_box(0));
}

extern "C" double get_demand_forecast(double base_attr, double capacity, uint8_t is_indoor, double rain, double flow) {
    init_zenrin_system();
    return calculate_demand_forecast(base_attr, capacity, is_indoor, rain, flow);
}

extern "C" double get_congestion_risk(double capacity, double rain, double flow) {
    init_zenrin_system();
    return calculate_congestion_risk(capacity, rain, flow);
}
