class CreateMenuLastProcesses < ActiveRecord::Migration[5.2]
  def change
    create_table :menu_last_processes do |t|
      t.integer :menu_id,null:false
      t.string :content,null:false,default:''
      t.string :memo
      t.timestamps
    end
  end
end
