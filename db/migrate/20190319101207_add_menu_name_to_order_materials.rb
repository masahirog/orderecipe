class AddMenuNameToOrderMaterials < ActiveRecord::Migration[5.2]
  def change
    add_column :order_materials, :menu_name, :text
    add_column :order_materials, :calculated_unit, :string
    add_column :order_materials, :order_unit, :string
  end
end
