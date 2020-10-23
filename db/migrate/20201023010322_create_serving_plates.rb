class CreateServingPlates < ActiveRecord::Migration[5.2]
  def change
    create_table :serving_plates do |t|
      t.string :name
      t.string :image
      t.integer :color
      t.integer :shape
      t.integer :genre
      t.timestamps
    end
  end
end
