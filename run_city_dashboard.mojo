from time import sleep

fn main() raises:
    # システム起動ログ
    print("--- 🏙️ Nagasaki City OS: Real-time Data Stream Initialized ---")
    
    # シミュレーション用の時刻カウンタ
    var tick: Int = 0

    # 無限ループでリアルタイムデータを送信し続ける
    while True:
        # ---------------------------------------------------------
        # 1. 物理エンジンからのデータ取得 (Physics Engine Layer)
        # ---------------------------------------------------------
        
        # [🍺 飲食] 雨宿り需要
        var dining_count = 40 + (tick % 5)
        var dining_capacity = 100 
        
        # [🏨 宿泊] チェックイン待ち
        var hotel_queue = 150 + (tick * 2)
        
        # [📸 観光] 屋外需要
        var tourism_outdoor = 120 - (tick * 5)
        if tourism_outdoor < 0:
            tourism_outdoor = 0
            
        # [🚖 交通] 混雑リスク
        var traffic_risk = 100
        
        # [🏛️ 行政] アラートレベル
        var alert_level = "RED"

        # ---------------------------------------------------------
        # 2. JSONデータの構築 (Data Structuring)
        # ---------------------------------------------------------
        # 修正: str() を String() に変更しました
        
        var json_str = String('{')
        
        # メタデータ
        json_str += '"timestamp": "2026-01-22T20:30:' + String(10 + tick) + '", '
        json_str += '"scenario": "heavy_rain", '
        json_str += '"tick": ' + String(tick) + ', '
        
        # データ本体
        json_str += '"data": {'
        
        # 🍺 Dining Data
        json_str += '"dining": {'
        json_str += '"count": ' + String(dining_count) + ', '
        json_str += '"capacity_rate": ' + String(dining_capacity) + ', '
        json_str += '"is_crowded": true'
        json_str += '}, '
        
        # 🏨 Hotel Data
        json_str += '"hotel": {'
        json_str += '"checkin_queue": ' + String(hotel_queue) + ', '
        json_str += '"prediction_wave": "rising"'
        json_str += '}, '
        
        # 📸 Tourism Data
        json_str += '"tourism": {'
        json_str += '"outdoor_visitors": ' + String(tourism_outdoor) + ', '
        json_str += '"suggest_indoor": true'
        json_str += '}, '

        # 🚖 Traffic Data
        json_str += '"traffic": {'
        json_str += '"congestion_risk": ' + String(traffic_risk) + ', '
        json_str += '"location": "stadium_south_gate"'
        json_str += '}, '

        # 🏛️ Government Data
        json_str += '"government": {'
        json_str += '"alert_level": "' + alert_level + '"'
        json_str += '}'
        
        json_str += '}' # end data
        json_str += '}' # end root

        # ---------------------------------------------------------
        # 3. データ送信 (Output)
        # ---------------------------------------------------------
        print(json_str)

        sleep(1.0)
        tick += 1
