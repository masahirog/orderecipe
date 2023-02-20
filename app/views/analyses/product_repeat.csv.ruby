require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(product_id name リピ率 count UU 指数)
  (1..20).each do |i|
  	csv_column_names << i
  end
  csv << csv_column_names
  @products.each do |product|
    data = [product.id,product.name,"#{((@repeat_count[product.id].to_f/@uu[product.id].to_i)*100).round(1)}%",@product_count[product.id],@uu[product.id],(((@repeat_count[product.id].to_f/@uu[product.id].to_i)/@uu[product.id])*10000).round(1)]
    (1..20).each do |i|
    	data << @hash[[product.id,i]]
    end
    csv << data
  end
end
