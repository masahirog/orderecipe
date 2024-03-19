class CreateItemOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :item_orders do |t|
      t.references :store,null:false
      t.date :delivery_date,null:false
      t.text :memo
      t.boolean :fixed_flag,null:false,default:false
      t.string :staff_name
      t.timestamps
    end
  end
end
