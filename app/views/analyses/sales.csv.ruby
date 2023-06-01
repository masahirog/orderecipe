require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(日付	店舗名	総売上	値引き合計	順売上	消費税	税抜売上	店舗売上	デリバリー売上	廃棄金額	廃棄率	ポイント利用	来客数	~16時客数	惣菜販売数	~16時販売数)
  csv << csv_column_names
  @analyses.each do |analysis|
		csv << [analysis.store_daily_menu.start_time,analysis.store_daily_menu.store.name,analysis.total_sales_amount,analysis.discount_amount,analysis.net_sales_amount,analysis.tax_amount,analysis.ex_tax_sales_amount,analysis.store_sales_amount,analysis.delivery_sales_amount,analysis.loss_amount,((analysis.loss_amount.to_f/analysis.ex_tax_sales_amount)*100).round(1),analysis.used_point_amount,analysis.transaction_count,
		analysis.fourteen_transaction_count,analysis.total_number_sales_sozai,analysis.fourteen_number_sales_sozai]
  end
end

