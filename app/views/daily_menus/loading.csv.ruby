hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
require 'csv'
bom = "\uFEFF"
CSV.generate(bom) do |csv|
  csv_column_names = %w(日付 店舗名 商品名 発注数 パーツ数 パーツ名 分量 積載容器 積載コンテナ 合算)
  csv << csv_column_names
  @daily_menu.store_daily_menus.each_with_index do |sdm,i|
    sdm.store_daily_menu_details.each do |sdmd|
      if sdmd.number == 0
      else
        sdmd.product.product_parts.each do |pp|
          if @loading_position.to_i == pp.loading_position_before_type_cast
            if sdmd.product.product_category == "お弁当" || sdmd.product.product_category == "その他"
              if sdm.store_id == 9 || sdm.store_id == 29
                store_id = 39
                store_name = "キッチン"
              else
                if sdm.store_id == 19
                  if sdmd.product.sell_price == 890
                    store_id = 39
                    store_name = "キッチン"
                  else
                    store_id = sdm.store_id
                    store_name = sdm.store.short_name
                  end
                else
                  store_id = sdm.store_id
                  store_name = sdm.store.short_name
                end
              end
            else
              store_id = sdm.store_id
              store_name = sdm.store.short_name            
            end
            if sdmd.bento_fukusai_number > 0
              if sdm.store_id == 9 || sdm.store_id == 29
                if pp.common_product_part_id.present?
                  amount = pp.amount*sdmd.number
                  if hash[store_id][pp.common_product_part_id].present?
                    hash[sdm.store_id][pp.common_product_part_id][:amount] += amount
                    hash[sdm.store_id][pp.common_product_part_id][:count] += 1
                    hash[sdm.store_id][pp.common_product_part_id][:number] += sdmd.sozai_number
                    hash[39][pp.common_product_part_id][:amount] += amount
                    hash[39][pp.common_product_part_id][:count] += 1
                    hash[39][pp.common_product_part_id][:number] += sdmd.bento_fukusai_number
                  else
                    hash[sdm.store_id][pp.common_product_part_id][:amount] = amount
                    hash[sdm.store_id][pp.common_product_part_id][:count] = 1
                    hash[sdm.store_id][pp.common_product_part_id][:number] = sdmd.sozai_number
                    hash[sdm.store_id][pp.common_product_part_id][:cpp] = pp.common_product_part
                    hash[39][pp.common_product_part_id][:amount] = amount
                    hash[39][pp.common_product_part_id][:count] = 1
                    hash[39][pp.common_product_part_id][:number] = sdmd.bento_fukusai_number
                    hash[39][pp.common_product_part_id][:cpp] = pp.common_product_part
                  end
                else
                  souzai_amount = number_with_precision(pp.amount*sdmd.sozai_number,precision:1, strip_insignificant_zeros: true, delimiter: ',')
                  bento_fukusai_amount = number_with_precision(pp.amount*sdmd.bento_fukusai_number,precision:1, strip_insignificant_zeros: true, delimiter: ',')
                  if pp.memo.present?
                    part_name = "#{pp.name} ※"
                  else
                    part_name = pp.name
                  end
                  parts_num = "パーツ：#{sdmd.product.product_parts.count}種"
                  csv << [@daily_menu.start_time.strftime("%-m/%-d"),store_name,sdmd.product.name,"発注数：#{sdmd.sozai_number}人前",parts_num,part_name,"#{souzai_amount} #{pp.unit}",pp.container,pp.loading_container,""]

                  csv << [@daily_menu.start_time.strftime("%-m/%-d"),'キッチン',sdmd.product.name,"副菜数：#{sdmd.bento_fukusai_number}人前",parts_num,part_name,"#{bento_fukusai_amount} #{pp.unit}",pp.container,pp.loading_container,""]
                end

              else
                if pp.common_product_part_id.present?
                  amount = pp.amount*sdmd.number
                  if hash[store_id][pp.common_product_part_id].present?
                    hash[store_id][pp.common_product_part_id][:amount] += amount
                    hash[store_id][pp.common_product_part_id][:count] += 1
                    hash[store_id][pp.common_product_part_id][:number] += sdmd.number
                  else
                    hash[store_id][pp.common_product_part_id][:amount] = amount
                    hash[store_id][pp.common_product_part_id][:count] = 1
                    hash[store_id][pp.common_product_part_id][:cpp] = pp.common_product_part
                    hash[store_id][pp.common_product_part_id][:number] = sdmd.number
                  end
                else
                  amount = number_with_precision(pp.amount*sdmd.number,precision:1, strip_insignificant_zeros: true, delimiter: ',')
                  if pp.memo.present?
                    part_name = "#{pp.name} ※"
                  else
                    part_name = pp.name
                  end
                  parts_num = "パーツ：#{sdmd.product.product_parts.count}種"
                  csv << [@daily_menu.start_time.strftime("%-m/%-d"),store_name,sdmd.product.name,"発注数：#{sdmd.number}人前",parts_num,part_name,"#{amount} #{pp.unit}",pp.container,pp.loading_container,""]
                end
              end
            else
              if pp.common_product_part_id.present?
                amount = pp.amount*sdmd.number
                if hash[store_id][pp.common_product_part_id].present?
                  hash[store_id][pp.common_product_part_id][:amount] += amount
                  hash[store_id][pp.common_product_part_id][:count] += 1
                  hash[store_id][pp.common_product_part_id][:number] += sdmd.number
                else
                  hash[store_id][pp.common_product_part_id][:amount] = amount
                  hash[store_id][pp.common_product_part_id][:count] = 1
                  hash[store_id][pp.common_product_part_id][:cpp] = pp.common_product_part
                  hash[store_id][pp.common_product_part_id][:number] = sdmd.number
                end
              else
                amount = number_with_precision(pp.amount*sdmd.number,precision:1, strip_insignificant_zeros: true, delimiter: ',')
                if pp.memo.present?
                  part_name = "#{pp.name} ※"
                else
                  part_name = pp.name
                end
                parts_num = "パーツ：#{sdmd.product.product_parts.count}種"
                csv << [@daily_menu.start_time.strftime("%-m/%-d"),store_name,sdmd.product.name,"発注数：#{sdmd.number}人前",parts_num,part_name,"#{amount} #{pp.unit}",pp.container,pp.loading_container,""]
              end
            end
          end
        end
      end
    end
  end
  hash.each do |data|
    store = Store.find(data[0])
    data[1].each do |cpp_data|
      amount = number_with_precision(cpp_data[1][:amount],precision:1, strip_insignificant_zeros: true, delimiter: ',')
      csv << [@daily_menu.start_time.strftime("%-m/%-d"),store.short_name,cpp_data[1][:cpp].product_name,"発注数：#{cpp_data[1][:number]}","",cpp_data[1][:cpp].name,"#{amount} #{cpp_data[1][:cpp].unit}",cpp_data[1][:cpp].container,cpp_data[1][:cpp].loading_container,"計#{cpp_data[1][:count]}種 合算"]
    end
  end
end
