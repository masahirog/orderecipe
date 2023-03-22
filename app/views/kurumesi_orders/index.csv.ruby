require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(商品ID 商品名 販売価格 原価 数)
  csv << csv_column_names
  @product_numbers.each do |id_number|
    product = Product.find(id_number[0])
    csv_column_values = [product.id,product.name,product.sell_price,product.cost_price,id_number[1]]
    csv << csv_column_values
  end
end
