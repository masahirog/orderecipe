require "csv"

CSV.foreach('db/sample4.csv') do |row|
  MenuMaterial.create(:menu_id => row[0], :material_id => row[1], :amount_used => row[2])
end
