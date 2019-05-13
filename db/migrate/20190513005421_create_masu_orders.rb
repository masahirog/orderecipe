class CreateMasuOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :masu_orders do |t|
      t.integer :number, default: 0, null: false
      t.date :start_time, null: false
      t.integer :kurumesi_order_id, null: false, unique: true
      t.time :pick_time
      t.boolean :fixed_flag,default:false,null:false

      t.timestamps
    end
  end
end
