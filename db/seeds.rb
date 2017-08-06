require "csv"

CSV.foreach('db/sample3.csv') do |row|
  MenuMaterial.create(:menu_id => row[0], :material_id => row[1], :amount_used => row[2], :cost_price => row[3])
end

CSV.foreach('db/sample2.csv') do |row|
  Material.create(:name => row[0], :delivery_slip_name => row[1], :calculated_value => row[2],
                  :calculated_unit => row[3], :calculated_price => row[4],
                  :cost_unit => row[5], :category => row[6], :vendor => row[7],
                  :code => row[8], :memo => row[9], :status => row[10], :cost_price => row[11])
end

CSV.foreach('db/sample4.csv') do |row|
  Menu.create(:name => row[2], :recipe => row[3], :category => row[1], :serving_memo => row[4])
end

CSV.foreach('db/sample1.csv') do |row|
  Product.create(:name => row[0], :cook_category => row[1], :product_type => row[2],
                  :sell_price => row[3], :description => row[4], :contents => row[5])
end
