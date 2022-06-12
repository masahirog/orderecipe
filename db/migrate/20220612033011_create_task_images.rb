class CreateTaskImages < ActiveRecord::Migration[6.0]
  def change
    create_table :task_images do |t|
      t.integer :task_id,null:false
      t.string :image
      t.timestamps
    end
  end
end
