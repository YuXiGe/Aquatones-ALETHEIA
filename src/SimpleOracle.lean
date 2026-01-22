import SciLean
open SciLean

-- ==========================================
-- 長崎スタジアムシティ × ゼンリン連携モデル
-- 都市OSコアロジック
-- ==========================================

structure POIData where
  base_attractiveness : Float -- 基礎集客力 (0.0 - 10.0)
  capacity : Float            -- キャパシティ (人)
  is_indoor : Bool            -- 屋内属性 (雨に強い)
  category : UInt8            -- 0:飲食, 1:宿泊, 2:観光, 3:交通, 4:行政

-- ■ 1. 売上・来客数予測 (飲食・観光・宿泊向け)
-- 天候と人流から、その場所の「稼ぐ力」を計算
@[export calculate_demand_forecast]
def calculate_demand_forecast 
  (base_attr : Float) (capacity : Float) (is_indoor_byte : UInt8) 
  (rain : Float) (flow_density : Float) : Float :=
  
  let is_indoor := is_indoor_byte > 0
  
  -- 雨の物理的影響 (屋外は魅力減、屋内は退避需要増)
  let weather_impact := 
    if is_indoor then 
      if rain > 0.5 then 1.5 else 1.0 -- 雨なら屋内施設の需要増 (特需)
    else 
      (1.0 - 0.9 * rain) -- 雨なら屋外施設の需要激減

  -- 人流密度と特需係数
  let predicted_visitors := flow_density * base_attr * weather_impact * 10.0
  
  -- キャパシティによる飽和
  if predicted_visitors > capacity then capacity else predicted_visitors

-- ■ 2. 混雑・リスク予測 (交通・行政向け)
-- 密度が高すぎると「危険(Risk)」判定が出る
@[export calculate_congestion_risk]
def calculate_congestion_risk 
  (capacity : Float) (rain : Float) (flow_density : Float) : Float :=
  
  -- 雨の日は傘で専有面積が増え、実質密度が上がる (係数 1.2)
  let effective_density := if rain > 0.0 then flow_density * 1.2 else flow_density
  
  -- リスクスコア (0.0 - 100.0)
  -- 密度 x 10 が基本スコア。キャパ超えで急上昇
  let risk := effective_density * 10.0
  if risk > 80.0 then 100.0 else risk

-- 疎通確認
@[export lean_zenrin_check]
def lean_zenrin_check (_ : Unit) : Float := 2026.0
