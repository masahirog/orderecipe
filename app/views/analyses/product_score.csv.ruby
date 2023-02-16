require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(日付 店舗名 商品ID 商品名 商品ID スコア 価格 在庫 定価販売数 16時販売数)
  csv << csv_column_names
  @products.each do |product|
    @dates.each do |date|
    	@store_hash[date][product.id].each do |store_data|
    		csv << [date,store_data[1]["store_name"],store_data[0],product.name,product.id,store_data[1]["nomination_rate"],product.sell_price,store_data[1]["actual_inventory"],store_data[1]["list_price_sales_number"],store_data[1]["early_sales_number"]]
    	end
    end
  end
end
