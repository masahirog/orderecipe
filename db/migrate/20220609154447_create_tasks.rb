class CreateTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :content
      t.integer :status
      t.string :drafter
      t.text :final_decision
      t.timestamps
      t.integer :row_order
      t.integer :category
      t.integer :group_id,null:false
      t.boolean :part_staffs_share_flag,default:0,null:false
    end
  end
end
