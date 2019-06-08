class AddEggToMaterial < ActiveRecord::Migration[4.2][5.0]
  def change
    add_column :materials, :allergy, :text, array: true
  end
end
