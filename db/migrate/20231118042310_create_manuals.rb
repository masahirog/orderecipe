class CreateManuals < ActiveRecord::Migration[6.0]
  def change
    create_table :manuals do |t|
    	t.text :content
    	t.string :title
    	t.string :video
      t.timestamps
			t.string :ancestry, index: true
    end
  end
end
