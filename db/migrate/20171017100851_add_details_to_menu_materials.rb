class AddDetailsToMenuMaterials < ActiveRecord::Migration[4.2][5.0]
  def change
    add_column :menu_materials, :preparation, :string
    add_column :menu_materials, :post, :string
  end
end
