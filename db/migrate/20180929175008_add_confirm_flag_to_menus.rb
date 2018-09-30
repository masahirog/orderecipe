class AddConfirmFlagToMenus < ActiveRecord::Migration[5.0]
  def change
    add_column :menus, :confirm_flag, :integer, null: false, default: 0
  end
end
