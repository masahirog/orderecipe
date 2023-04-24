require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(日付 店舗名 商品名 卸単価 発注量 単位 卸価格計 メモ スタッフ名)
  csv << csv_column_names
    @order_materials.each do |om|
      order_quantity = om.order_quantity.to_f/om.material.recipe_unit_quantity
      order_price = om.order_quantity.to_f * om.material.cost_price
      csv_column_values = [
        om.delivery_date,om.order.store.name,om.material.name,(om.material.cost_price*om.material.recipe_unit_quantity),order_quantity,om.material.order_unit,order_price,
        om.order_material_memo,om.order.staff_name
      ]
      csv << csv_column_values
    end
  end
