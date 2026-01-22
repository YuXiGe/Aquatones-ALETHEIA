from memory import UnsafePointer, alloc
from python import Python

fn main() raises:
    print("================================================================")
    print("   🏦 AQUATONES-ALETHEIA: Bank Certificate Generator")
    print("================================================================")
    
    # 1. 必要なPythonモジュールのロード (JSON, UUID, Datetime, OS, Ctypes)
    var ffi = Python.import_module("ctypes")
    var os = Python.import_module("os")
    var json = Python.import_module("json")
    var uuid = Python.import_module("uuid")
    var datetime = Python.import_module("datetime")
    var builtins = Python.import_module("builtins") # open関数用

    # 2. ブリッジライブラリのロード
    var lib_path = String(os.getcwd()) + "/build/libPhysicsOracleBridge.so"
    var lib = ffi.CDLL(lib_path)

    # 型定義 (Float入力 -> UInt8出力)
    lib.verify_asset_value.argtypes = [ffi.c_double, ffi.c_double, ffi.c_double, ffi.c_double]
    lib.verify_asset_value.restype = ffi.c_uint8

    # 3. 監査データセット
    var count: Float64 = 9200.0
    var avg_weight: Float64 = 0.21
    var prev_total: Float64 = 2000.0
    var days: Float64 = 7.0
    var current_total_weight = count * avg_weight

    print("Checking Asset...")
    print(" -> Count: " + String(Int(count)))
    print(" -> Weight: " + String(current_total_weight) + " kg")

    # 4. SciLeanによる監査実行
    var result_code = lib.verify_asset_value(
        ffi.c_double(count), 
        ffi.c_double(avg_weight), 
        ffi.c_double(prev_total), 
        ffi.c_double(days)
    )
    var status = Int(result_code)

    # 5. 証明書発行プロセス
    if status == 1:
        print("✅ AUDIT PASSED. Generating Digital Certificate...")
        
        # 証明書データの構築 (Python辞書オブジェクト)
        var cert_data = Python.dict()
        
        # ヘッダー情報
        cert_data["certificate_id"] = String(uuid.uuid4())
        cert_data["issue_date"] = String(datetime.datetime.now().isoformat())
        cert_data["location"] = "Nagasaki Stadium City / Marine Unit 01"
        
        # 資産情報
        var asset_info = Python.dict()
        asset_info["species"] = "Mackerel (Saba)"
        asset_info["count"] = count
        asset_info["total_weight_kg"] = current_total_weight
        asset_info["estimated_value_jpy"] = current_total_weight * 1200.0 # 単価仮定
        cert_data["asset_data"] = asset_info

        # 監査情報
        var audit_info = Python.dict()
        audit_info["engine"] = "SciLean (Lean 4 Formal Verification)"
        audit_info["logic_version"] = "v1.0.0-integer-safe"
        audit_info["result_code"] = status
        audit_info["status"] = "APPROVED"
        cert_data["audit_verification"] = audit_info

        # JSONファイルへの書き出し
        var json_str = String(json.dumps(cert_data, indent=2))
        var file_name = "bank_audit_certificate.json"
        
        # Pythonのopen()を使って書き込み
        var f = builtins.open(file_name, "w")
        f.write(json_str)
        f.close()

        print("----------------------------------------------------------------")
        print("📄 Certificate Saved: " + file_name)
        print("----------------------------------------------------------------")
        print(json_str) # コンソールにも表示
        print("----------------------------------------------------------------")
        print("Ready for upload to Banking API.")

    else:
        print("🚨 AUDIT FAILED. Certificate cannot be issued.")
