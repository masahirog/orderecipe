class AddMagnesiumToFoodIngredients < ActiveRecord::Migration[4.2][5.0]
  def change
    add_column :food_ingredients, :magnesium, :float
    add_column :food_ingredients, :iron, :float
    add_column :food_ingredients, :zinc, :float
    add_column :food_ingredients, :copper, :float
    add_column :food_ingredients, :folic_acid, :float
    add_column :food_ingredients, :vitamin_d, :float
  end
end

