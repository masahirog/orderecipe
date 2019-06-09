class AddGramQuantityToMenuMaterial < ActiveRecord::Migration[4.2][5.0]
  def change
    add_column :menu_materials, :gram_quantity, :float
    add_column :menu_materials, :food_ingredient_id, :integer
    add_column :menu_materials, :calorie, :float
    add_column :menu_materials, :protein, :float
    add_column :menu_materials, :lipid, :float
    add_column :menu_materials, :carbohydrate, :float
    add_column :menu_materials, :dietary_fiber, :float
    add_column :menu_materials, :potassium, :float
    add_column :menu_materials, :calcium, :float
    add_column :menu_materials, :vitamin_b1, :float
    add_column :menu_materials, :vitamin_b2, :float
    add_column :menu_materials, :vitamin_c, :float
    add_column :menu_materials, :salt, :float
  end
end

