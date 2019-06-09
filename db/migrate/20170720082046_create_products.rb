class CreateProducts < ActiveRecord::Migration[4.2]
  def change
    create_table :products do |t|
      t.string :name
      t.string :cook_category
      t.string :product_type
      t.integer :sell_price
      t.text :description
      t.text :contents
      t.float :cost_price
      t.string :product_image
      t.integer :bento_id
      t.text :memo
      t.string :short_name, unique: true
      t.text :masu_obi_url

      t.timestamps null: false
    end
  end
end
