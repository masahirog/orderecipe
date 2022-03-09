class CreateOrders < ActiveRecord::Migration[4.2][5.0]
  def change
    create_table :orders do |t|
      t.timestamps
      t.boolean :fixed_flag,null:false,default:false
      t.string :staff_name
      t.integer :store_id
    end
  end
end
