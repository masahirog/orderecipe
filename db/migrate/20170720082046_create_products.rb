class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.string :cook_category
      t.string :product_type
      t.integer :sell_price
      t.text :description
      t.text :contents
      t.timestamps null: false
    end
  end
end
