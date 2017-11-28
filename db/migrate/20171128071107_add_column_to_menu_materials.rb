class AddColumnToMenuMaterials < ActiveRecord::Migration[5.0]
  def change
    add_column :menu_materials, :row_order, :integer
  end
end
