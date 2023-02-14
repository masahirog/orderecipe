require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(日付 店舗名 商品ID 商品名 16時販売数 合計販売数 在庫)
  csv << csv_column_names
  @analyses.each do |analysis|
    analysis.analysis_products.each do |ap|
      if ap.product_id.present?
        csv << [analysis.store_daily_menu.start_time,analysis.store.name,ap.product_id,ap.product.name,ap.early_sales_number,ap.sales_number,ap.actual_inventory]
      end
    end
  end
end
