class CreateManualDirectories < ActiveRecord::Migration[6.0]
  def change
    create_table :manual_directories do |t|
      t.string :title
      t.string :ancestry, index: true
      t.timestamps
    end
  end
end
