class CreateWorkTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :work_types do |t|
      t.string :name
      t.references :group
      t.timestamps
      t.integer :row_order
    end
  end
end
