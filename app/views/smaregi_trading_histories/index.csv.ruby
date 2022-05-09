require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(日付 時間 analysis_id 取引ID 合計金額 数量合計 店舗ID 会員ID 会員コード 取引明細区分 商品ID 品番（product_id） 商品名 商品単価 数量 値引き合計)
  csv << csv_column_names
  @smaregi_trading_histories.each do |sth|
    csv << [sth.date,sth.time.strftime("%H:%M"),sth.analysis_id,sth.torihiki_id,sth.gokei,sth.suryo_gokei,sth.tenpo_id,sth.kaiin_id,
            sth.kaiin_code,sth.torihiki_meisaikubun,sth.shohin_id,sth.hinban,sth.shohinmei,sth.shohintanka,sth.suryo,sth.nebikigokei]
  end
end
