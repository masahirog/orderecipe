require 'csv'
CSV.generate(encoding: Encoding::SJIS, row_sep: "\r\n", force_quotes: true) do |csv|
  csv_column_names = %w(主菜 副菜1 副菜2 副菜3 ポタージュ)
  csv << csv_column_names
  @sdmds.each do |sdmd|
    product = sdmd.product
    if product.sell_price == 890
      sdmd.sozai_number.times{
        csv << [product.food_label_name,@fukusai1.food_label_name,@fukusai2.food_label_name,@fukusai3,@soup.food_label_name]
      }
    else
      sdmd.sozai_number.times{
        csv << [product.food_label_name,@fukusai1.food_label_name,@fukusai2.food_label_name,@fukusai3,'']
      }
    end
  end
end