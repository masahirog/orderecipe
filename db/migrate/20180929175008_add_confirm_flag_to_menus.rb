class AddConfirmFlagToMenus < ActiveRecord::Migration[4.2][5.0]
  def change
    add_column :menus, :confirm_flag, :integer, null: false, default: 0
  end
end
