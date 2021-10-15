class CreateStoreProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :store_products do |t|
      t.integer :store_id,null:false
      t.integer :product_id,null:false
      t.integer :sales_potential,null:false,default:0
      t.integer :sales_count,null:false,default:0
      t.timestamps
    end
  end
end
