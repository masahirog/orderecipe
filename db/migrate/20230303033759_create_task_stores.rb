class CreateTaskStores < ActiveRecord::Migration[6.0]
  def change
    create_table :task_stores do |t|
    	t.integer :task_id
    	t.integer :store_id
    	t.boolean :subject_flag,default:false
      t.timestamps
    end
  end
end
