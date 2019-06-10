class CreateMasuOrders < ActiveRecord::Migration[4.2][5.2]
  def change
    create_table :masu_orders do |t|
      t.date :start_time, null: false
      t.integer :kurumesi_order_id, null: false, unique: true
      t.time :pick_time
      t.integer :payment,null:false,default:0
      t.boolean :canceled_flag,default:false,null:false
      t.integer :billed_amount,default:0,null:false

      t.timestamps
    end
  end
end
