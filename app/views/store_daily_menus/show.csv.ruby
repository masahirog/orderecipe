require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(名称 原材料 内容量 消費期限 保存方法 製造者)
  csv << csv_column_names
    @store_daily_menu.store_daily_menu_details.each do |sdmd|
      csv_column_values = [sdmd.product.food_label_name,sdmd.product.food_label_content,
        '1人前',@date.strftime("%Y.%-m.%-d"),'要冷蔵（10℃以下で保存）','株式会社べじはん 東京都中野区東中野1-35-1']
      sdmd.number.times{
        csv << csv_column_values
      }
    end
  end
