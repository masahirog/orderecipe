require 'csv'
bom = "\uFEFF"
CSV.generate(bom) do |csv|
  csv_column_names = %w(日付 店舗名 商品名 パーツ名 人前 分量)
  csv << csv_column_names
  @daily_menu.store_daily_menus.each_with_index do |sdm,i|
    sdm.store_daily_menu_details.each do |sdmd|
      if sdmd.number == 0
      else
        sdmd.product.product_parts.each do |pp|
          if pp.sticker_print_flag == true
            amount = number_with_precision(pp.amount*sdmd.number,precision:1, strip_insignificant_zeros: true, delimiter: ',')
            if pp.memo.present?
              part_name = "#{pp.name} ※"
            else
              part_name = pp.name
            end
            csv << [@daily_menu.start_time,sdm.store.short_name,sdmd.product.name,part_name,sdmd.number,"#{amount} #{pp.unit}"]
          end
        end
      end
    end
  end
end
