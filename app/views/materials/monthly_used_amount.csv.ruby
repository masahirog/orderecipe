require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(年 月 食材ID 食材名 業者名 単位 単位 単価（税別） 使用量 単位 金額（税別） 発注量)
  csv << csv_column_names
  @material_hash.each do |hash|
    csv_column_values = [@year,@month,hash[0],hash[1][:material].name,@vendor_hash[hash[1][:material].vendor_id],
    1,hash[1][:material].accounting_unit,"#{hash[1][:material].cost_price * hash[1][:material].accounting_unit_quantity}",
    (hash[1][:amount_used].round(1)/hash[1][:material].accounting_unit_quantity).round(1),hash[1][:material].accounting_unit,"#{hash[1][:amount_price].round().to_s(:delimited)}",(hash[1][:order_amount].round(1)/hash[1][:material].accounting_unit_quantity).round(1)]
    csv << csv_column_values
  end
end
