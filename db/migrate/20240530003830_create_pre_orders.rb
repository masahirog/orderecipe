class CreatePreOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :pre_orders do |t|
      t.references :store,null:false
      t.date :date,null:false
      t.time :recipient_time,null:false
      t.integer :employee_id
      t.string :recipient_name
      t.string :tel
      t.integer :status,null:false,default:0
      t.text :memo
      t.timestamps
    end
  end
end
