class ChangeDatatypeCalculatedPriceOfMaterials < ActiveRecord::Migration[4.2][5.0]
  def change
    change_column :materials, :calculated_price, :float
  end
end
