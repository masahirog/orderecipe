class AddMenuNameToOrderMaterials < ActiveRecord::Migration[5.2]
  def change
    add_column :order_materials, :menu_name, :text
  end
end
