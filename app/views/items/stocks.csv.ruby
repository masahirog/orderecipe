require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(店舗ID 店舗名 日付 商品ID 商品名 仕入先 仕入れ値 在庫 在庫金額)
  csv << csv_column_names
  @item_store_stocks.each do |iss|
    csv_column_values = [
      iss.store_id,iss.store.short_name,iss.date,iss.item_id,iss.item.name,iss.item.item_vendor.store_name,
      "1#{iss.item.unit}：#{iss.item.purchase_price.to_s(:delimited)}円",iss.stock,(iss.unit_price * iss.stock).to_i.to_s(:delimited)
    ]
    csv << csv_column_values
  end
end
