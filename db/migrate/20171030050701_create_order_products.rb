class CreateOrderProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :order_products do |t|
      t.integer :order_id
      t.integer :product_id
      t.integer :serving_for
      t.timestamps
    end
  end
end
