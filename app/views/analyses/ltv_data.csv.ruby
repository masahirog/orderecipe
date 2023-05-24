require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(店舗ID 取引ID 日付 会員ID 登録日 合計金額 購入点数 時間 販売員)
  csv << csv_column_names
  @hash.each do |data|
  	csv << [data[1][:tenpo_id],data[0],data[1][:date],data[1][:kaiin_id],data[1][:nyukaibi],data[1][:gokei],data[1][:suryo_gokei],data[1][:time],data[1][:hanbaiin_id]]
  end
end
