class AddDeliveryDateToOrderMaterials < ActiveRecord::Migration[4.2][5.0]
  def change
    add_column :order_materials, :delivery_date, :string
  end
end
