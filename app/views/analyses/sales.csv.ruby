require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(日付	店舗名	総売上	値引き合計	順売上	消費税	税抜売上	店舗売上	デリバリー売上	廃棄金額	廃棄率	ポイント利用	来客数	~16時客数	惣菜販売数	~16時販売数 自社製品売上 他社製品売上 自社製品値引 他社製品値引)
  csv << csv_column_names
  @analyses.each do |analysis|
		csv << [analysis.store_daily_menu.start_time,analysis.store_daily_menu.store.name,analysis.total_sales_amount,analysis.discount_amount,analysis.net_sales_amount,analysis.tax_amount,analysis.ex_tax_sales_amount,analysis.store_sales_amount,analysis.delivery_sales_amount,analysis.loss_amount,((analysis.loss_amount.to_f/analysis.ex_tax_sales_amount)*100).round(1),analysis.used_point_amount,analysis.transaction_count,
		analysis.sixteen_transaction_count,analysis.total_sozai_sales_number,analysis.sixteen_sozai_sales_number,@date_analysis_categories[analysis.date][:foods][:ex_tax_sales_amount],@date_analysis_categories[analysis.date][:goods][:ex_tax_sales_amount],@date_analysis_categories[analysis.date][:foods][:discount_amount],@date_analysis_categories[analysis.date][:goods][:discount_amount]]
  end
end

