class AddColumnToOrderMaterials < ActiveRecord::Migration[4.2][5.0]
  def change
    add_column :order_materials, :calculated_quantity, :float
  end
end
