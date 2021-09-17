class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.integer :store_id,null:false
      t.integer :task_template_id
      t.datetime :action_datetime
      t.string :content
      t.text :memo
      t.integer :status
      t.datetime :status_change_datetime
      t.timestamps
    end
  end
end
