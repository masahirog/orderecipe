class CreateProducts < ActiveRecord::Migration[4.2]
  def change
    create_table :products do |t|
      t.string :name, unique: true
      t.integer :sell_price
      t.text :description
      t.text :contents
      t.float :cost_price
      t.string :image
      t.integer :management_id
      t.string :short_name
      t.string :symbol
      t.integer :status,default:1,null:false
      t.integer :brand_id
      t.integer :product_category,null:false,default:1
      t.integer :cooking_rice_id,null:false
      t.timestamps null: false
    end
  end
end
