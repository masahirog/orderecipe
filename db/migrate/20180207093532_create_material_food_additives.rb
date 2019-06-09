class CreateMaterialFoodAdditives < ActiveRecord::Migration[4.2][5.0]
  def change
    create_table :material_food_additives do |t|
      t.integer :material_id, null:false
      t.integer :food_additive_id, null:false

      t.timestamps
    end
  end
end
