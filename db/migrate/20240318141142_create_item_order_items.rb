class CreateItemOrderItems < ActiveRecord::Migration[6.0]
  def change
    create_table :item_order_items do |t|
      t.references :item_order,null:false
      t.references :item,null:false
      t.string :order_quantity,null:false,default:0
      t.string :memo
      t.boolean :un_order_flag,default:false,null:false
      t.timestamps
      t.index [:item_order_id, :item_id], unique: true
    end
  end
end
