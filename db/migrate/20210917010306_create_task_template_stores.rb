class CreateTaskTemplateStores < ActiveRecord::Migration[5.2]
  def change
    create_table :task_template_stores do |t|
      t.integer :task_template_id,null:false
      t.integer :store_id,null:false
      t.timestamps
    end
  end
end
