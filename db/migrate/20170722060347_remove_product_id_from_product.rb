class RemoveProductIdFromProduct < ActiveRecord::Migration
  def change
    remove_column :products, :product_id, :integer
  end
end
