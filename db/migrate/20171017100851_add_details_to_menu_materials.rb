class AddDetailsToMenuMaterials < ActiveRecord::Migration[5.0]
  def change
    add_column :menu_materials, :preparation, :string
    add_column :menu_materials, :post, :string
  end
end
