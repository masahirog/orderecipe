class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.integer :store_id,null:false
      t.integer :task_template_id
      t.date :action_date,null:false
      t.time :action_time
      t.string :content,null:false,default:''
      t.text :memo
      t.integer :status,null:false,default:0
      t.datetime :status_change_datetime
      t.string :drafter,null:false,default:''
      t.timestamps
      t.boolean :important_flag,null:false,default:0
    end
  end
end
