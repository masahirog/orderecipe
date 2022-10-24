class CreateMenuProcesses < ActiveRecord::Migration[6.0]
  def change
    create_table :menu_processes do |t|
      t.integer :menu_id
      t.string :image
      t.text :memo
      t.timestamps
    end
  end
end
