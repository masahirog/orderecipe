class AddColumnToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :bento_id, :integer
  end
end
