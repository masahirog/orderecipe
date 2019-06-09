class CreateMenuMaterials < ActiveRecord::Migration[4.2]
  def change
    create_table :menu_materials do |t|
      t.integer :menu_id
      t.integer :material_id
      t.float :amount_used
      t.string :preparation
      t.string :post
      t.integer :row_order
      t.float :gram_quantity
      t.integer :food_ingredient_id
      t.float :calorie
      t.float :protein
      t.float :lipid
      t.float :carbohydrate
      t.float :dietary_fiber
      t.float :potassium
      t.float :calcium
      t.float :vitamin_b1
      t.float :vitamin_b2
      t.float :vitamin_c
      t.float :salt
      t.float :magnesium
      t.float :iron
      t.float :zinc
      t.float :copper
      t.float :folic_acid
      t.float :vitamin_d

      t.timestamps
    end
  end
end
