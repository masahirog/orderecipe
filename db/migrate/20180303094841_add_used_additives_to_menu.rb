class AddUsedAdditivesToMenu < ActiveRecord::Migration[5.0]
  def change
    add_column :menus, :used_additives, :string
  end
end
