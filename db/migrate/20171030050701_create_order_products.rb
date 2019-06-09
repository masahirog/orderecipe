class CreateOrderProducts < ActiveRecord::Migration[4.2][5.0]
  def change
    create_table :order_products do |t|
      t.integer :order_id,null:false
      t.integer :product_id,null:false
      t.integer :serving_for
      t.date :make_date
      t.timestamps
    end
  end
end
