class CreateKurumesiOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :kurumesi_orders do |t|
      t.date :start_time, null: false
      t.integer :management_id, null: false
      t.time :pick_time
      t.integer :payment,null:false,default:0
      t.boolean :canceled_flag,default:false,null:false
      t.integer :billed_amount,default:0,null:false
      t.text :memo
      t.integer :brand_id,null:false
      t.boolean :confirm_flag,default:false,null:false
      t.time :delivery_time
      t.string :company_name
      t.string :staff_name
      t.string :delivery_address
      t.string :reciept_name
      t.string :proviso
      t.integer :total_price,default:0
      t.boolean :capture_done,default:false,null:false
      t.timestamps
      t.text :kitchen_memo
    end
  end
end
