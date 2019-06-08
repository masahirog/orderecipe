class AddMagnesiumToMenuMaterials < ActiveRecord::Migration[4.2][5.0]
  def change
    add_column :menu_materials, :magnesium, :float
    add_column :menu_materials, :iron, :float
    add_column :menu_materials, :zinc, :float
    add_column :menu_materials, :copper, :float
    add_column :menu_materials, :folic_acid, :float
    add_column :menu_materials, :vitamin_d, :float
  end
end
