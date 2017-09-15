require "csv"

# CSV.foreach('db/h_material_seed1.csv') do |row|
#   Material.create!(:name => row[0], :order_name => row[1], :calculated_value => row[2], :calculated_unit => row[3],
#   :calculated_price => row[4], :cost_price => row[5], :category => row[6],
#   :vendor_id => row[7], :order_code => row[8],:memo => row[9], :end_of_sales => row[10])
# end

# CSV.foreach('db/h_material_seed2.csv') do |row|
#   Material.create!(:name => row[0], :order_name => row[1], :calculated_value => row[2], :calculated_unit => row[3],
#   :calculated_price => row[4], :cost_price => row[5], :category => row[6],
#   :vendor_id => row[7], :order_code => row[8],:memo => row[9], :end_of_sales => row[10])
# end

CSV.foreach('db/h_menu_material_seed.csv') do |row|
  MenuMaterial.create!(:menu_id => row[0], :material_id => row[1], :amount_used => row[2])
end

CSV.foreach('db/h_menu_seed.csv') do |row|
  Menu.create!(:name => row[1], :recipe => row[2], :category => row[0], :serving_memo => row[3])
end

# CSV.foreach('db/product_seed.csv') do |row|
#   Product.create!(:name => row[0], :cook_category => row[1], :product_type => row[2],
#                   :sell_price => row[3], :description => row[4], :contents => row[5])
# end

CSV.foreach('db/h_vendor_seed.csv') do |row|
  Vendor.create!(:company_name => row[0], :company_phone => row[1], :company_fax => row[2], :company_mail => row[3],
                :zip => row[4],:address => row[5], :staff_name => row[6], :staff_phone => row[7], :staff_mail => row[8], :memo => row[9])
end

User.find_or_create_by(id: 1) do |user|
  user.email = 'gon@bento.jp'
  user.password = 'password'
end
