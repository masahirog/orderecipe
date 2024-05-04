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
  products = Product.where(status:1)
  update_products = []
  products.each do |product|
    product.cost_price = (product.product_menus.map{|pm| pm.menu.cost_price }.sum).round(1)
    update_products << product
  end
  Product.import update_products, :on_duplicate_key_update => [:cost_price], validate: false
end

# masahiro11g@gmailのアカウントでGASを書いている。未開封の新着メールがあれば、下記の2個のタスクを実行するという流れ。
# herokuの負荷を下げるために、こちらのスクリプトでチェックして必要なときだけOrderのタスクを実行する
task :order_fax_status_check => :environment do
  Order.fax_send_check
  # Slack::Notifier.new("https://hooks.slack.com/services/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", username: 'bot', icon_emoji: ':sunglasses:').ping("movfax_check_done")
end


# # 毎日の0:00にheroku_schedulerをセット
# task :update_need_inventory_flag => :environment do
#   Store.all.each do |store|
#     Stock.stock_status_check(store.id)
#   end
# end


task :reminder_bulk_create => :environment do
  Reminder.reminder_bulk_create
end

task :store_order_close => :environment do
  if Date.today.wday == 5 || Date.today.wday == 1
    DailyMenu.store_order_close
  end
end


task :item_expiration_date_notice => :environment do
  ItemExpirationDate.expiration_date_notice
end


task :kpi_notice => :environment do
  Analysis.send_report
end
