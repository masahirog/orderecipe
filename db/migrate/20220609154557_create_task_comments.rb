class CreateTaskComments < ActiveRecord::Migration[6.0]
  def change
    create_table :task_comments do |t|
      t.integer :task_id,null:false
      t.text :content
      t.string :name
      t.timestamps
      t.string :image
    end
  end
end
