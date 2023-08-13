require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(店舗ID 店舗名 日付 来客数 純売上(税抜) ロス率 値引き率 廃棄率 10%OFF 20%OFF 30%OFF 50%OFF LINE 社割り その他割引 廃棄 ポイント利用)
  csv << csv_column_names
  @dates.each do |date|
	  count = ""
		sales = ""
		loss_rate = ""
		discount_rate = ""
		discard_rate = ""
		ten_per_off = ""
		twenty_per_off = ""
		thirty_per_off = ""
		fifty_per_off = ""
		kaiin_toroku_off = ""
		staff_off = ""
		other_off = ""
		date_loss_amoun = ""
		point_off = ""
		count = @date_transaction_count[date] if @date_transaction_count[date]
		sales = @date_sales_amount[date].to_s(:delimited) if @date_sales_amount[date]
		loss_rate = "#{(((@date_loss_amount[date].to_f + @date_discount_amount[date].to_f)/@date_sales_amount[date])*100).round(1)}%" if @date_loss_amount[date] && @date_sales_amount[date]
		discount_rate = "#{((@date_discount_amount[date].to_f/@date_sales_amount[date])*100).round(1)}%" if @date_discount_amount[date]
		discard_rate = "#{((@date_loss_amount[date].to_f/@date_sales_amount[date])*100).round(1)}%" if @date_loss_amount[date]
		ten_per_off = @ten_per_off[date].to_s(:delimited) if @ten_per_off[date]
		twenty_per_off = @twenty_per_off[date].to_s(:delimited) if @twenty_per_off[date]
		thirty_per_off = @thirty_per_off[date].to_s(:delimited) if @thirty_per_off[date]
		fifty_per_off = @fifty_per_off[date].to_s(:delimited) if @fifty_per_off[date]
		kaiin_toroku_off = @kaiin_toroku_off[date].values.sum.to_s(:delimited)  if @kaiin_toroku_off[date].present?
		staff_off = @staff_off[date].values.sum.to_s(:delimited) if @staff_off[date].present?
		other_off = @other_off[date].values.sum.to_s(:delimited) if @other_off[date].present?
		date_loss_amoun = @date_loss_amount[date].to_s(:delimited) if @date_loss_amount[date]
		point_off = @point_off[date].values.sum.to_s(:delimited)
		date = date.strftime("%Y/%-m/%-d (#{%w(日 月 火 水 木 金 土)[date.wday]})")
  	csv << [@stores.ids.join(","),@stores.map{|store|store.short_name}.join(","),date,count,sales,loss_rate,discount_rate,discard_rate,ten_per_off,twenty_per_off,thirty_per_off,fifty_per_off,kaiin_toroku_off,staff_off,other_off,date_loss_amoun,point_off]
  end
end