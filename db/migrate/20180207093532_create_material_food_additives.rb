class CreateMaterialFoodAdditives < ActiveRecord::Migration[5.0]
  def change
    create_table :material_food_additives do |t|
      t.integer :material_id
      t.integer :food_additive_id

      t.timestamps
    end
  end
end
