require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(日付 店舗名 発注先 商品ID 商品名 発注量 単位 単価 卸価格 メモ スタッフ名)
  csv << csv_column_names
    @order_materials.each do |om|
      order_quantity = om.order_quantity.to_f/om.material.recipe_unit_quantity
      order_price = om.order_quantity.to_f * om.material.cost_price
      csv_column_values = [
        om.delivery_date,om.order.store.name,om.material.vendor.name,om.material_id,om.material.name,order_quantity,om.material.order_unit,(om.material.recipe_unit_price/om.material.order_unit_quantity),order_price,
        om.order_material_memo,om.order.staff_name
      ]
      csv << csv_column_values
    end
  end
