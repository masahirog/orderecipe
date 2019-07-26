class CreateKurumesiOrderDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :kurumesi_order_details do |t|
      t.integer :kurumesi_order_id, null:false
      t.integer :product_id, null:false
      t.integer :number, null:false,default:0

      t.timestamps
    end
  end
end
