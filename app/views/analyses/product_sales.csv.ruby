require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(日付 店舗 商品ID 商品 部門 価格 在庫 16時 定価販売 値引販売 廃棄 指名率 ポテンシャル 売上)
  csv << csv_column_names
  @product_store_sales.each do |pss|
    pss[1].each do |data|
      data[1].each do |store_data|
        csv_data =[data[0],store_data[0],pss[0],store_data[1][:shohinmei],store_data[1][:bumon_id],store_data[1][:sell_price],store_data[1][:actual_inventory],store_data[1][:sixteen_total_sales_number],store_data[1][:list_price_sales_number],
          store_data[1][:discount_number],store_data[1][:loss_number],store_data[1][:nomination_rate],store_data[1][:potential],store_data[1][:sales]]
        csv << csv_data
      end
    end
  end
end
