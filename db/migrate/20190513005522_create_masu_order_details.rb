class CreateMasuOrderDetails < ActiveRecord::Migration[4.2][5.2]
  def change
    create_table :masu_order_details do |t|
      t.integer :masu_order_id, null:false
      t.integer :product_id, null:false
      t.integer :number, null:false,default:0

      t.timestamps
    end
  end
end
