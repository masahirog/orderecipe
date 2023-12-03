class CreateManuals < ActiveRecord::Migration[6.0]
  def change
    create_table :manuals do |t|
      t.integer :manual_directory_id,null:false
    	t.text :content
    	t.string :picture
      t.integer :row_order, default: 0, null: false
      t.timestamps
    end
  end
end
