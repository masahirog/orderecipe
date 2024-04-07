class AnalysisCategory < ApplicationRecord
  belongs_to :analysis



#   def self.recalculate
#     store_id = 164
#     new_arr = []
#     analyses = Analysis.where(store_id:store_id)
#     analyses.each do |analysis|
#       date = analysis.date
#       number = 0
#       analysis_total_sales_amount = 0
#       analysis_discount_amount = 0
#       analysis_net_sales_amount = 0
#       analysis_ex_tax_sales_amount = 0
#       analysis_tax_amount = 0
#       analysis_store_sales_amount = 0
#       analysis_delivery_sales_amount = 0
#       analysis_used_point_amount = 0
#       torihiki_ids = []
#       sixteen_transaction_count = 0
#       transaction_count = 0
#       total_sales = 0
#       total_sozai_sales_number = 0
#       sixteen_sozai_sales_number = 0
#       smaregi_trading_histories_arr = []
#       product_sales_number = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
#       product_sixteen_total_sales_number = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
#       product_sales_amount = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
#       analysis_category_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
#       product_ids = []
#       kaiin_raitensu_hash = {}
#       update_smaregi_members_arr = []
#       analysis.smaregi_trading_histories.each do |smaregi_trading_history|
#         torihiki_id = smaregi_trading_history.torihiki_id
#         shohinmei = smaregi_trading_history.shohinmei
#         tanka_nebikimae_shokei = smaregi_trading_history.tanka_nebikimae_shokei.to_i
#         tanka_nebiki_shokei = smaregi_trading_history.tanka_nebiki_shokei.to_i
#         shokei = smaregi_trading_history.shokei.to_i
#         shokei_nebiki = smaregi_trading_history.shokei_nebiki.to_i
#         point_nebiki = smaregi_trading_history.point_nebiki.to_i
#         gokei = smaregi_trading_history.gokei.to_i
#         tenpo_id = smaregi_trading_history.tenpo_id
#         torihiki_meisaikubun = smaregi_trading_history.torihiki_meisaikubun
#         shohin_id = smaregi_trading_history.shohin_id
#         hinban = smaregi_trading_history.hinban
#         shohintanka = smaregi_trading_history.shohintanka.to_i
#         tanka_nebikikei = smaregi_trading_history.tanka_nebikikei.to_i
#         suryo = smaregi_trading_history.suryo.to_i
#         nebikigokei = smaregi_trading_history.nebikigokei.to_i
#         time = "#{smaregi_trading_history.time.hour}:#{smaregi_trading_history.time.min}"
#         shiharaihouhou = smaregi_trading_history.shiharaihouhou
#         bumonmei = smaregi_trading_history.bumonmei
#         bumon_id = smaregi_trading_history.bumon_id
#         nebikimaekei = smaregi_trading_history.nebikimaekei.to_i
#         uchishohizei = smaregi_trading_history.uchishohizei.to_i
#         uchizeianbun = smaregi_trading_history.uchizeianbun.to_i
#         shokei_nebiki_anbun = smaregi_trading_history.shokei_nebiki_anbun.to_i
#         point_nebiki_anbun = smaregi_trading_history.point_nebiki_anbun.to_i
#         sotozei_anbun = smaregi_trading_history.sotozei_anbun.to_i
#         shain_nebiki_anbun = smaregi_trading_history.shain_nebiki_anbun.to_i
#         sale_nebiki_anbun = smaregi_trading_history.sale_nebiki_anbun.to_i
#         tanpin_waribiki = smaregi_trading_history.tanpin_waribiki
#         product_zeinuki_uriage = nebikigokei - uchizeianbun
#         nebiki_anubn = shokei_nebiki_anbun + point_nebiki_anbun + shain_nebiki_anbun + sale_nebiki_anbun
#         analysis_category_hash[bumon_id] = {zeinuki_uriage:0,net_sales_amount:0,sales_number:0,sales_amount:0,discount_amount:0} unless analysis_category_hash[bumon_id].present?
#         if torihiki_meisaikubun == 1 ||torihiki_meisaikubun == 3
#           transaction_count += 1 unless torihiki_ids.include?(torihiki_id)
#           total_sozai_sales_number += suryo if bumon_id == 1
#           if Time.parse(time) < Time.parse('16:00')
#             sixteen_sozai_sales_number += suryo if bumon_id == 1
#             sixteen_transaction_count += 1 unless torihiki_ids.include?(torihiki_id)
#           end
#           # analysis_categoryの部分の更新
#           analysis_category_hash[bumon_id][:zeinuki_uriage] += product_zeinuki_uriage - nebiki_anubn
#           analysis_category_hash[bumon_id][:net_sales_amount] += nebikigokei - nebiki_anubn
#           analysis_category_hash[bumon_id][:sales_number] += suryo
#           analysis_category_hash[bumon_id][:sales_amount] += nebikimaekei
#           analysis_category_hash[bumon_id][:discount_amount] += tanka_nebikikei + nebiki_anubn

#         elsif torihiki_meisaikubun == 2
#           transaction_count -= 1 unless torihiki_ids.include?(torihiki_id)
#           total_sozai_sales_number -= suryo if bumon_id == 1

#           # analysis_categoryの部分の更新
#           analysis_category_hash[bumon_id][:zeinuki_uriage] -= product_zeinuki_uriage + nebiki_anubn
#           analysis_category_hash[bumon_id][:net_sales_amount] -= nebikigokei + nebiki_anubn
#           analysis_category_hash[bumon_id][:sales_number] -= suryo
#           analysis_category_hash[bumon_id][:sales_amount] -= nebikimaekei
#           analysis_category_hash[bumon_id][:discount_amount] -= tanka_nebikikei - nebiki_anubn
#         end

#         # ▼analysisの更新部分
#         unless torihiki_ids.include?(torihiki_id)
#           tanka_nebikimae_shokei = tanka_nebikimae_shokei #総売上
#           nebiki = tanka_nebiki_shokei + shokei_nebiki
#           used_point_amount = point_nebiki.to_i
#           gokei = gokei #純売上
#           ex_tax_sales_amount = gokei - uchishohizei #税抜売上
#           if shiharaihouhou == 3
#             delivery_sales_amount = ex_tax_sales_amount
#             store_sales_amount = 0
#           else
#             delivery_sales_amount = 0
#             store_sales_amount = ex_tax_sales_amount
#           end
#           torihiki_ids << torihiki_id
#           # analysisの更新はtorihikimeisaikubunは関係ない（商品データのみ影響する ）
#           analysis_total_sales_amount += tanka_nebikimae_shokei
#           analysis_discount_amount += nebiki
#           analysis_net_sales_amount += gokei
#           analysis_ex_tax_sales_amount += ex_tax_sales_amount
#           analysis_tax_amount += uchishohizei
#           analysis_store_sales_amount += store_sales_amount
#           analysis_delivery_sales_amount += delivery_sales_amount
#           analysis_used_point_amount += used_point_amount
#         end
#       end
#       analysis.update(total_sales_amount:analysis_total_sales_amount,transaction_count:transaction_count,sixteen_transaction_count:sixteen_transaction_count,
#         total_sozai_sales_number:total_sozai_sales_number,sixteen_sozai_sales_number:sixteen_sozai_sales_number,discount_amount:analysis_discount_amount,
#         net_sales_amount:analysis_net_sales_amount,tax_amount:analysis_tax_amount,ex_tax_sales_amount:analysis_ex_tax_sales_amount,store_sales_amount:analysis_store_sales_amount,
#         delivery_sales_amount:analysis_delivery_sales_amount,used_point_amount:analysis_used_point_amount)
#       analysis_category_hash.each do |analysis_bumon_data|
#         analysis_id = analysis.id
#         smaregi_bumon_id = analysis_bumon_data[0]
#         ex_tax_sales_amount = analysis_bumon_data[1][:zeinuki_uriage]
#         net_sales_amount = analysis_bumon_data[1][:net_sales_amount]
#         sales_number = analysis_bumon_data[1][:sales_number]
#         sales_amount = analysis_bumon_data[1][:sales_amount]
#         discount_amount = analysis_bumon_data[1][:discount_amount]
#         new_arr << AnalysisCategory.new(analysis_id:analysis_id,smaregi_bumon_id:smaregi_bumon_id,sales_number:sales_number,sales_amount:sales_amount,discount_amount:discount_amount,
#               net_sales_amount:net_sales_amount,ex_tax_sales_amount:ex_tax_sales_amount)
#       end
#     end
#     AnalysisCategory.import new_arr
#   end
end


# FOOD
# 1：惣菜
# 2：ご飯・丼
# 3：ドリンク・デザート
# 4：備品
# 5：お弁当
# 6：オードブル
# 7：スープ
# 8：惣菜（仕入れ）
# 9：レジ修正
# 11：オプション
# 13：デリバリー商品

# VEGE
# 14：物販/青果
# 16：予約ギフト
# 17：物販/青果（野菜）
# 18：物販/青果（果実）

# GOODS
# 15：物販/物産