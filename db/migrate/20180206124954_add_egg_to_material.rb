class AddEggToMaterial < ActiveRecord::Migration[5.0]
  def change
    add_column :materials, :allergy, :text, array: true
  end
end
