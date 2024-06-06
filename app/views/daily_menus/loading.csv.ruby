hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
require 'csv'
bom = "\uFEFF"
CSV.generate(bom) do |csv|
  csv_column_names = %w(店舗名 日付 商品名 発注数 パーツ数 パーツ名 分量 梱包 積載)
  csv << csv_column_names
  @daily_menu.store_daily_menus.each_with_index do |sdm,i|
    sdm.store_daily_menu_details.each do |sdmd|
      if sdmd.number == 0
      else
        sdmd.product.product_parts.each do |pp|
          if pp.common_product_part_id.present?
            amount = pp.amount*sdmd.number
            if hash[sdm.store_id][pp.common_product_part_id].present?
              hash[sdm.store_id][pp.common_product_part_id][:amount] += amount
              hash[sdm.store_id][pp.common_product_part_id][:count] += 1
              hash[sdm.store_id][pp.common_product_part_id][:number] += sdmd.number
            else
              hash[sdm.store_id][pp.common_product_part_id][:amount] = amount
              hash[sdm.store_id][pp.common_product_part_id][:count] = 1
              hash[sdm.store_id][pp.common_product_part_id][:cpp] = pp.common_product_part
              hash[sdm.store_id][pp.common_product_part_id][:number] = sdmd.number
            end
          else
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
  hash.each do |data|
    store = Store.find(data[0])
    data[1].each do |cpp_data|
      amount = number_with_precision(cpp_data[1][:amount],precision:1, strip_insignificant_zeros: true, delimiter: ',')
      csv << [@daily_menu.start_time,store.short_name,"計#{cpp_data[1][:count]}種 合算",cpp_data[1][:cpp].name,cpp_data[1][:number],"#{amount} #{cpp_data[1][:cpp].unit}"]
    end
  end
end
