class CreateProducts < ActiveRecord::Migration[4.2]
  def change
    create_table :products do |t|
      t.string :name, unique: true
      t.integer :cook_category
      t.integer :product_type
      t.integer :sell_price
      t.text :description
      t.text :contents
      t.float :cost_price
      t.string :image
      t.integer :management_id
      t.text :memo
      t.string :short_name, unique: true
      t.text :obi_url
      t.integer :brand_id
      t.integer :product_category,null:false,default:1
      t.timestamps null: false
    end
  end
end
