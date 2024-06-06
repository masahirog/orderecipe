require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(店舗名 日付 商品ID 商品名 店頭価格 卸単価 発注数 卸価格計)
  csv << csv_column_names
    @store_daily_menus.each do |store_daily_menu|
      store_daily_menu.store_daily_menu_details.each do |sdmd|
        if sdmd.number > 0 || sdmd.actual_inventory > 0
          csv_column_values = [
            sdmd.store_daily_menu.store.name,sdmd.store_daily_menu.start_time,sdmd.product_id,
            sdmd.product.name,sdmd.product.sell_price,(sdmd.product.sell_price*0.58),sdmd.number,
            (sdmd.product.sell_price*0.58*sdmd.number)]
          csv << csv_column_values
        end
      end
    end
  end
