require 'csv'
CSV.generate(encoding: Encoding::SJIS, row_sep: "\r\n", force_quotes: true) do |csv|
  csv_column_names = %w(バーコード 産地  商品名 税抜き 税込  日付)
  csv << csv_column_names
  @hash.each do |data|
    sell_price = data[1]["sell_price"]
    sell_price_length = sell_price.length
    sell_price = "0"*(5 - sell_price_length) + sell_price
    data[1]["subordinate_amount"].to_i.times{
      csv << ["12#{data[1]['smaregi_code']}#{sell_price}",data[1]['vendor'],data[1]['name'],data[1]["sell_price"],"税込#{data[1]['tax_including_sell_price']}円",data[1]["sales_life"]]
    }
  end
end
