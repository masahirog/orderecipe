class CreateBuppanSchedules < ActiveRecord::Migration[6.0]
  def change
    create_table :buppan_schedules do |t|
      t.date :date,unique: true
      t.boolean :fixed_flag,default:false,null:false
      t.timestamps
    end
  end
end
