class CreateItemStoreStocks < ActiveRecord::Migration[6.0]
  def change
    create_table :item_store_stocks do |t|
      t.date :date
      t.integer :item_id,null:false
      t.integer :store_id,null:false
      t.integer :unit,null:false
      t.integer :unit_price,null:false
      t.float :stock,null:false,default:0
      t.integer :stock_price,null:false,default:0
      t.index [:date,:item_id,:store_id], unique: true
      t.timestamps
    end
  end
end
