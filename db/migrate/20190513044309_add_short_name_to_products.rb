class AddShortNameToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :short_name, :string, unique: true
  end
end
