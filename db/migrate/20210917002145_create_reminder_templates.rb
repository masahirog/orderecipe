class CreateReminderTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :reminder_templates do |t|
      t.integer :repeat_type,null:false
      t.time :action_time
      t.string :content,null:false
      t.text :memo
      t.integer :status,null:false,default:0
      t.string :drafter,null:false,default:''
      t.timestamps
      t.integer :category,null:false,default:0
      t.boolean :important_flag,null:false,default:0
      t.string :image
    end
  end
end
