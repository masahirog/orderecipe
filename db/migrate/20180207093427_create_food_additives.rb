class CreateFoodAdditives < ActiveRecord::Migration[4.2][5.0]
  def change
    create_table :food_additives do |t|
      t.string :name, unique: true

      t.timestamps
    end
  end
end
