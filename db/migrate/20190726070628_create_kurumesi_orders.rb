class CreateKurumesiOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :kurumesi_orders do |t|
      t.date :start_time, null: false
      t.integer :management_id, null: false, unique: true
      t.time :pick_time
      t.integer :payment,null:false,default:0
      t.boolean :canceled_flag,default:false,null:false
      t.integer :billed_amount,default:0,null:false
      t.text :memo
      t.integer :brand_id,null:false
      t.timestamps
    end
  end
end
