class CreateTaskStaffs < ActiveRecord::Migration[6.0]
  def change
    create_table :task_staffs do |t|
      t.integer :task_id,null:false
      t.integer :staff_id,null:false
      t.boolean :read_flag,null:false,default:false
      t.timestamps
    end
  end
end
