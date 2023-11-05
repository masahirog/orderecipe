require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(商品ID 商品名 日付)
  csv << csv_column_names
  date = @store_daily_menu.start_time  
  @store_daily_menu.store_daily_menu_details.each do |sdmd|
    sdmd.sozai_number.times{
      csv << [sdmd.product_id,sdmd.product.name,date]
    }
  end
end