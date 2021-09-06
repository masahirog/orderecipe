require "csv"
class SmaregiTradingHistory < ApplicationRecord
  belongs_to :analysis


  def self.upload_data(form_date,smaregi_store_id,analysis_id,file)
    smaregi_trading_histories_arr = []
    analysis_products_arr = []
    smaregi_shohin_ids = []
    CSV.foreach file.path, {encoding: 'BOM|UTF-8', headers: true} do |row|
      row = row.to_hash
      torihiki_id = row["取引ID"]
      torihiki_nichiji = row["取引日時"]
      date = torihiki_nichiji.to_date
      tanka_nebikimae_shokei = row["単価値引き前小計"]
      tanka_nebiki_shokei = row["単価値引き小計"]
      shokei = row["小計"]
      shikei_nebiki = row["小計値引き"]
      shokei_waribikiritsu = row["小計割引率"]
      point_nebiki = row["ポイント値引き"]
      gokei = row["合計"]
      suryo_gokei = row["数量合計"]
      henpinsuryo_gokei = row["返品数量合計"]
      huyo_point = row["付与ポイント"]
      shiyo_point = row["使用ポイント"]
      genzai_point = row["現在ポイント"]
      gokei_point = row["合計ポイント"]
      tenpo_id = row["店舗ID"]
      kaiin_id = row["会員ID"]
      kaiin_code = row["会員コード"]
      tanmatsu_torihiki_id = row["端末取引ID"]
      nenreiso = row["年齢層"]
      kyakuso_id = row["客層ID"]
      hanbaiin_id = row["販売員ID"]
      hanbaiin_mei = row["販売員名"]
      torihikimeisai_id = row["取引明細ID"]
      torihiki_meisaikubun = row["取引明細区分 （1：通常、2：返品、3：部門売り）"]
      shohin_id = row["商品ID"]
      shohin_code = row["商品コード"]
      hinban = row["品番"]
      shohinmei = row["商品名"]
      shohintanka = row["商品単価"]
      hanbai_tanka = row["販売単価"]
      tanpin_nebiki = row["単品値引"]
      tanpin_waribiki = row["単品割引"]
      suryo = row["数量"]
      nebikimaekei = row["値引き前計"]
      tanka_nebikikei = row["単価値引き計"]
      nebikigokei = row["値引き後計"]
      bumon_id = row["部門ID"]
      bumonmei = row["部門名"]
      if date == form_date.to_date && smaregi_store_id == tenpo_id
        new_smaregi_trading_history = SmaregiTradingHistory.new(date:date,analysis_id:analysis_id,torihiki_id:torihiki_id,torihiki_nichiji:torihiki_nichiji,tanka_nebikimae_shokei:tanka_nebikimae_shokei,
          tanka_nebiki_shokei:tanka_nebiki_shokei,shokei:shokei,shikei_nebiki:shikei_nebiki,shokei_waribikiritsu:shokei_waribikiritsu,
          point_nebiki:point_nebiki,gokei:gokei,suryo_gokei:suryo_gokei,henpinsuryo_gokei:henpinsuryo_gokei,huyo_point:huyo_point,
          shiyo_point:shiyo_point,genzai_point:genzai_point,gokei_point:gokei_point,tenpo_id:tenpo_id,kaiin_id:kaiin_id,kaiin_code:kaiin_code,
          tanmatsu_torihiki_id:tanmatsu_torihiki_id,nenreiso:nenreiso,kyakuso_id:kyakuso_id,hanbaiin_id:hanbaiin_id,hanbaiin_mei:hanbaiin_mei,
          torihikimeisai_id:torihikimeisai_id,torihiki_meisaikubun:torihiki_meisaikubun,shohin_id:shohin_id,shohin_code:shohin_code,
          hinban:hinban,shohinmei:shohinmei,shohintanka:shohintanka,hanbai_tanka:hanbai_tanka,tanpin_nebiki:tanpin_nebiki,tanpin_waribiki:tanpin_waribiki,
          suryo:suryo,nebikimaekei:nebikimaekei,tanka_nebikikei:tanka_nebikikei,nebikigokei:nebikigokei,bumon_id:bumon_id,bumonmei:bumonmei)
        smaregi_trading_histories_arr << new_smaregi_trading_history


        if smaregi_shohin_ids.include?(shohin_id)
        else
          new_analysis_product = AnalysisProduct.new(analysis_id:analysis_id,smaregi_shohin_id:shohin_id,smaregi_shohin_name:shohinmei,smaregi_shohintanka:shohintanka,
          product_id:hinban,total_sales_amount:0,salse_number:0)
          analysis_products_arr << new_analysis_product
          smaregi_shohin_ids << shohin_id
        end
      end
    end
    SmaregiTradingHistory.import smaregi_trading_histories_arr
    AnalysisProduct.import analysis_products_arr
    total_sales = SmaregiTradingHistory.where(analysis_id:analysis_id).sum(:nebikigokei)
    Analysis.find(analysis_id).update(sales_amount:total_sales.to_i)
    return (smaregi_trading_histories_arr.count)
  end
end
