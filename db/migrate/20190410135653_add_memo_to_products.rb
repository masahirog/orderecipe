class AddMemoToProducts < ActiveRecord::Migration[4.2][5.2]
  def change
    add_column :products, :memo, :text
  end
end

