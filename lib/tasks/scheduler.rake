# 毎日の23:00にheroku_schedulerをセット
task :update_menu_cost_price => :environment do
  menus = Menu.all
  menus.each do |menu|
    menu.cost_price = (menu.menu_materials.map{|mm| mm.amount_used * mm.material.cost_price}.sum).round(2)
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

#10分毎に実行
task :kurumesi_order_mail_check => :environment do
  KurumesiMail.routine_check
  Order.fax_send_check
  # KurumesiOrder.capture_check
end

# 毎日の0:00にheroku_schedulerをセット
task :update_need_inventory_flag => :environment do
  Stock.stock_status_check
end

task :capa_check => :environment do
  KurumesiOrder.capacity_check
end

task :input_gss => :environment do
  Product.input_spreadsheet
end

task :pick_time_get => :environment do
  KurumesiOrder.pick_time_scraping
end

task :reminder_bulk_create => :environment do
  Task.reminder_bulk_create
end
