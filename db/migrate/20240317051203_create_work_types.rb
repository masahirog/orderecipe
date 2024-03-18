class CreateWorkTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :work_types do |t|
      t.string :name
      t.references :group
      t.timestamps
    end
  end
end
