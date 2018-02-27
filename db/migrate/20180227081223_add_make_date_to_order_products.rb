class AddMakeDateToOrderProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :order_products, :make_date, :string
  end
end
