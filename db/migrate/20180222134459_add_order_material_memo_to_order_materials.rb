class AddOrderMaterialMemoToOrderMaterials < ActiveRecord::Migration[4.2][5.0]
  def change
    add_column :order_materials, :order_material_memo, :string
  end
end

