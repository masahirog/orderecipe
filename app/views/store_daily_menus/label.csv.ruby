require 'csv'
bom = "\uFEFF"
CSV.generate(bom) do |csv|
  csv_column_names = %w(商品名 税抜き 税込み バーコード)
  csv << csv_column_names
  @store_daily_menu_details.each do |sdmd|
    product = sdmd.product
    sdmd.sozai_number.times{
      csv << [product.food_label_name,product.sell_price,"（税込 #{product.tax_including_sell_price}円）",product.smaregi_code]
    }
  end
end