require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(ID 従業員番号 名前 日付 時間 店舗 ステータス メモ 合計金額 商品ID 商品 税込単価 個数 小計 福利厚生 社割)
  csv << csv_column_names
  @monthly_pre_orders.each do |pre_order|
  	pre_order.pre_order_products.each do |pop|
  		csv_column_values = [
	    	pre_order.id,pre_order.employee_id,pre_order.recipient_name,pre_order.date,pre_order.recipient_time.strftime('%H:%M'),pre_order.store.short_name,
	    	pre_order.status,pre_order.memo,pre_order.total,pop.product_id,pop.product.food_label_name,pop.tax_including_sell_price,
	    	pop.order_num,pop.subtotal,pop.welfare_price,pop.employee_discount
	    ]
	    csv << csv_column_values
  	end
  end
end
