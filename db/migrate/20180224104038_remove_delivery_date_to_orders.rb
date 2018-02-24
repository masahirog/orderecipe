class RemoveDeliveryDateToOrders < ActiveRecord::Migration[5.0]
  def change
    remove_column :orders, :delivery_date, :string
  end
end
