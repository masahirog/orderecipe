require 'csv'
CSV.generate(encoding: Encoding::SJIS, row_sep: "\r\n", force_quotes: true) do |csv|
  csv_column_names = %w(バーコード 産地  商品名 税抜き 税込  日付)
  csv << csv_column_names
  day = @date.to_date.day
  @daily_item_stores.each do |dis|
    if dis.subordinate_amount > 0
      item = dis.daily_item.item
      dis.subordinate_amount.times{
        csv << [%(="020119230#{dis.tax_including_sell_price}3"),"#{item.item_vendor.area} #{item.item_vendor.store_name}","#{item.name} #{item.variety}",dis.sell_price,"(税込#{dis.tax_including_sell_price}円)",day]
      }
    end
  end
end
