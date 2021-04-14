require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(店舗名 日付 商品ID 商品名 販売価格 発注数 在庫追加分 実在庫 繰越分 完売)
  csv << csv_column_names
    @store_daily_menus.each do |store_daily_menu|
      store_daily_menu.store_daily_menu_details.each do |sdmd|
        if sdmd.sold_out_flag == true
          kanbai = true
        else
          kanbai = ''
        end
        csv_column_values = [
          sdmd.store_daily_menu.store.name,sdmd.store_daily_menu.start_time,sdmd.product_id,sdmd.product.name,sdmd.product.sell_price,sdmd.number,
          sdmd.stock_deficiency_excess,sdmd.carry_over,sdmd.actual_inventory,kanbai
        ]
        csv << csv_column_values
      end
    end
  end
