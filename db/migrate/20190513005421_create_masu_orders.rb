class CreateMasuOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :masu_orders do |t|
      t.integer :number, default: 0, null: false
      t.date :start_time, null: false
      t.integer :kurumesi_order_id, null: false, unique: true
      t.time :pick_time
      t.boolean :fixed_flag,default:false,null:false
      t.integer :payment,null:false,default:0
      t.integer :tea,null:false,default:0
      t.integer :miso,null:false,default:0

      t.timestamps
    end
  end
end
