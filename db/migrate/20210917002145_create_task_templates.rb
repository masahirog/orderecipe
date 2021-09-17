class CreateTaskTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :task_templates do |t|
      t.integer :repeat_type,null:false
      t.time :action_time
      t.string :content
      t.text :memo
      t.integer :status,null:false,default:0
      t.timestamps
    end
  end
end
