require 'csv'
CSV.generate(encoding: Encoding::SJIS, row_sep: "\r\n", force_quotes: true) do |csv|
  csv_column_names = %w(商品名 税抜き 税込み バーコード)
  csv << csv_column_names
  @number.times{
    csv << [@label_name,@sell_price,"（税込 #{@tax_including_sell_price}円）",@product.smaregi_code]
  }
end