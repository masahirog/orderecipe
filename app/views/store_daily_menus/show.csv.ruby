require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(名称 原材料 内容量 消費期限 保存方法 製造者)
  csv << csv_column_names
    @store_daily_menu.store_daily_menu_details.each do |sdmd|
      csv_column_values = [sdmd.product.food_label_name,sdmd.product.food_label_content,
        '1人前',@date.strftime("%Y.%-m.%-d"),'要冷蔵（10℃以下で保存）','日本フードデリバリー株式会社 東京都渋谷区道玄坂2-10-12']
      sdmd.number.times{
        csv << csv_column_values
      }
    end
  end
