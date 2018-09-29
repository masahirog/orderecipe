class CreateFoodIngredients < ActiveRecord::Migration[5.0]
  def change
    create_table :food_ingredients do |t|
      t.integer :food_group
      t.integer :food_number
      t.integer :index_number
      t.string :name
      t.string :complement
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
      t.text :memo

      t.timestamps
    end
  end
end
