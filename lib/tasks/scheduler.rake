# 毎日の23:00にheroku_schedulerをセット
task :update_menu_cost_price => :environment do
  menus = Menu.all
  menus.each do |menu|
    menu.cost_price = (menu.menu_materials.map{|mm| mm.amount_used * mm.material.cost_price}.sum * 1.08).round(2)
  end
  Menu.import menus.to_a, :on_duplicate_key_update => [:cost_price]
end

# 毎日の0:00にheroku_schedulerをセット
task :update_product_cost_price => :environment do
  products = Product.all
  products.each do |product|
    product.cost_price = (product.product_menus.map{|pm| pm.menu.cost_price }.sum).round(1)
  end
  Product.import products.to_a, :on_duplicate_key_update => [:cost_price]
end
