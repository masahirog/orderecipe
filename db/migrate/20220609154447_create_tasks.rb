class CreateTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :content
      t.integer :status
      t.string :drafter
      t.text :final_decision
      t.timestamps
    end
  end
end
