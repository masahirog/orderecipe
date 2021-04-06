require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(店舗名 日付 商品名 販売価格 個数)
  csv << csv_column_names
    @store_daily_menus.each do |store_daily_menu|
      store_daily_menu.store_daily_menu_details.each do |sdmd|
        csv_column_values = [
          sdmd.store_daily_menu.store.name,sdmd.store_daily_menu.start_time,sdmd.product.name,sdmd.product.sell_price,sdmd.number
        ]
        csv << csv_column_values
      end
    end
  end
