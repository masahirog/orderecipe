require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(日付 時間 店舗ID 取引ID 会員ID 会員コード 合計金額)
  csv << csv_column_names
  @sths.each do |sth|
    csv << [sth.date,sth.time,sth.tenpo_id,sth.torihiki_id,sth.kaiin_id,sth.kaiin_code,sth.gokei]
  end
end
