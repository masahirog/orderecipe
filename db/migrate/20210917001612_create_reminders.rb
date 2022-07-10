class CreateReminders < ActiveRecord::Migration[5.2]
  def change
    create_table :reminders do |t|
      t.integer :store_id,null:false
      t.integer :reminder_template_id
      t.date :action_date,null:false
      t.time :action_time
      t.string :content,null:false,default:''
      t.text :memo
      t.integer :status,null:false,default:0
      t.datetime :status_change_datetime
      t.string :drafter,null:false,default:''
      t.timestamps
      t.boolean :important_flag,null:false,default:0
      t.integer :category,null:false,default:0
      t.integer :do_staff
      t.integer :check_staff
    end
  end
end
