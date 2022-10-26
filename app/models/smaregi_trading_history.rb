require "csv"
class SmaregiTradingHistory < ApplicationRecord
  belongs_to :analysis

  def self.once_uploads_data(file,first_day,last_day,store_id)

    @one_month = [*first_day..last_day]
    @one_month.each do |date|
      torihiki_ids = []
      fourteen_transaction_count = 0
      transaction_count = 0
      total_sales = 0
      total_early_sales_number = 0
      total_number_sales_sozai = 0
      fourteen_number_sales_sozai = 0
      smaregi_trading_histories_arr = []
      analysis_products_arr = []
      update_analysis_products_arr = []
      hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
      product_sales_number = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
      product_early_sales_number = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
      product_sales_amount = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
      analysis = Analysis.find_by(date:date,store_id:store_id)
      if analysis.present?
        analysis_id = analysis.id
        product_ids = analysis.analysis_products.map{|ap|ap.product_id.to_s}
        kaiin_raitensu_hash = {}
        update_smaregi_members_arr = []
        CSV.foreach file.path, {encoding: 'BOM|UTF-8', headers: true} do |row|
          row = row.to_hash
          torihiki_id = row["取引ID"]
          torihiki_nichiji = row["取引日時"]
          torihiki_date = torihiki_nichiji.to_date
          tanka_nebikimae_shokei = row["単価値引き前小計"]
          tanka_nebiki_shokei = row["単価値引き小計"]
          shokei = row["小計"]
          shikei_nebiki = row["小計値引き"]
          shokei_waribikiritsu = row["小計割引率"]
          point_nebiki = row["ポイント値引き"]
          gokei = row["合計"]
          suryo_gokei = row["数量合計"]
          henpinsuryo_gokei = row["返品数量合計"]
          huyo_point = row["付与ポイント"]
          shiyo_point = row["使用ポイント"]
          genzai_point = row["現在ポイント"]
          gokei_point = row["合計ポイント"]
          tenpo_id = row["店舗ID"]
          kaiin_id = row["会員ID"]
          kaiin_code = row["会員コード"]
          tanmatsu_torihiki_id = row["端末取引ID"]
          nenreiso = row["年齢層"]
          kyakuso_id = row["客層ID"]
          hanbaiin_id = row["販売員ID"]
          hanbaiin_mei = row["販売員名"]
          torihikimeisai_id = row["取引明細ID"]
          torihiki_meisaikubun = row["取引明細区分 （1：通常、2：返品、3：部門売り）"]
          shohin_id = row["商品ID"]
          shohin_code = row["商品コード"]
          hinban = row["品番"]
          shohinmei = row["商品名"]
          shohintanka = row["商品単価"]
          hanbai_tanka = row["販売単価"]
          tanpin_nebiki = row["単品値引"]
          tanpin_waribiki = row["単品割引"]
          suryo = row["数量"]
          nebikimaekei = row["値引き前計"]
          tanka_nebikikei = row["単価値引き計"]
          nebikigokei = row["値引き後計"]
          bumon_id = row["部門ID"]
          bumonmei = row["部門名"]
          time = "#{Time.parse(torihiki_nichiji).hour}:#{Time.parse(torihiki_nichiji).min}"
          uchikeshi_torihiki_id = row["打消取引ID"]
          uchikeshi_kubun = row["打消区分(0：通常、1：打消元レコード、2：打消レコード)"]
          receipt_number = row["レシート番号"]
          shiharaihouhou = row["支払方法ID1"]
          uchishohizei = row["内消費税"]
          uchizeianbun = row["内税按分"]
          zeinuki_uriage = nebikigokei.to_i - uchizeianbun.to_i
          if hinban == '10459' ||hinban == '12899'||hinban == '13179'||hinban == '14099'
            loss_ignore = true
          else
            loss_ignore = false
          end
          if date == torihiki_date
            new_smaregi_trading_history = SmaregiTradingHistory.new(date:torihiki_date,analysis_id:analysis_id,torihiki_id:torihiki_id,torihiki_nichiji:torihiki_nichiji,tanka_nebikimae_shokei:tanka_nebikimae_shokei,
              tanka_nebiki_shokei:tanka_nebiki_shokei,shokei:shokei,shikei_nebiki:shikei_nebiki,shokei_waribikiritsu:shokei_waribikiritsu,
              point_nebiki:point_nebiki,gokei:gokei,suryo_gokei:suryo_gokei,henpinsuryo_gokei:henpinsuryo_gokei,huyo_point:huyo_point,
              shiyo_point:shiyo_point,genzai_point:genzai_point,gokei_point:gokei_point,tenpo_id:tenpo_id,kaiin_id:kaiin_id,kaiin_code:kaiin_code,
              tanmatsu_torihiki_id:tanmatsu_torihiki_id,nenreiso:nenreiso,kyakuso_id:kyakuso_id,hanbaiin_id:hanbaiin_id,hanbaiin_mei:hanbaiin_mei,
              torihikimeisai_id:torihikimeisai_id,torihiki_meisaikubun:torihiki_meisaikubun,shohin_id:shohin_id,shohin_code:shohin_code,
              hinban:hinban,shohinmei:shohinmei,shohintanka:shohintanka,hanbai_tanka:hanbai_tanka,tanpin_nebiki:tanpin_nebiki,tanpin_waribiki:tanpin_waribiki,
              suryo:suryo,nebikimaekei:nebikimaekei,tanka_nebikikei:tanka_nebikikei,nebikigokei:nebikigokei,bumon_id:bumon_id,bumonmei:bumonmei,time:time,
              uchikeshi_torihiki_id:uchikeshi_torihiki_id,uchikeshi_kubun:uchikeshi_kubun,receipt_number:receipt_number,shiharaihouhou:shiharaihouhou,
              uchishohizei:uchishohizei,uchizeianbun:uchizeianbun,zeinuki_uriage:zeinuki_uriage)
            smaregi_trading_histories_arr << new_smaregi_trading_history
            if product_ids.include?(hinban)
            else
              new_analysis_product = AnalysisProduct.new(analysis_id:analysis_id,smaregi_shohin_id:shohin_id,smaregi_shohin_name:shohinmei,smaregi_shohintanka:shohintanka,
              product_id:hinban,total_sales_amount:0,sales_number:0,loss_amount:0,early_sales_number:0,bumon_id:bumon_id,bumon_mei:bumonmei,
              discount_amount:0,net_sales_amount:0,ex_tax_sales_amount:0,discount_rate:0,loss_ignore:loss_ignore)

              analysis_products_arr << new_analysis_product
              product_ids << hinban
              hash[hinban]={sales_number:0,total_sales_amount:0,discount_amount:0,net_sales_amount:0,ex_tax_sales_amount:0,early_sales_number:0,delivery_sales_amount:0,store_sales_amount:0,tax_amount:0,loss_amount:0}
            end

            number = suryo.to_i #販売数
            nebikimaekei = nebikimaekei.to_i #総売上
            nebikigokei = nebikigokei.to_i #純売上

            unless torihiki_ids.include?(torihiki_id)
              nebiki = tanka_nebiki_shokei.to_i + shikei_nebiki.to_i
              ex_tax_sales_amount = gokei.to_i - uchishohizei.to_i #税抜売上
              tax_amount = uchishohizei.to_i
              if shiharaihouhou == '3'
                delivery_sales_amount = ex_tax_sales_amount
                store_sales_amount = 0
              else
                delivery_sales_amount = 0
                store_sales_amount = ex_tax_sales_amount
              end
            else
              nebiki = 0
              ex_tax_sales_amount = 0
              tax_amount = 0
              store_sales_amount = 0
              delivery_sales_amount = 0
            end
            if torihiki_meisaikubun == '1'
              transaction_count += 1 unless torihiki_ids.include?(torihiki_id)
              total_number_sales_sozai += number if bumon_id == "1"
              hash[hinban][:sales_number] += number
              hash[hinban][:total_sales_amount] += nebikimaekei
              hash[hinban][:discount_amount] += nebiki
              hash[hinban][:net_sales_amount] += nebikigokei
              hash[hinban][:ex_tax_sales_amount] += ex_tax_sales_amount
              hash[hinban][:delivery_sales_amount] += delivery_sales_amount
              hash[hinban][:store_sales_amount] += store_sales_amount
              hash[hinban][:tax_amount] += tax_amount

              if Time.parse(time) < Time.parse('14:00')
                hash[hinban][:early_sales_number] += number
                fourteen_number_sales_sozai += number if bumon_id == "1"
                fourteen_transaction_count += 1 unless torihiki_ids.include?(torihiki_id)
              end

              # 会員情報の来店数更新
              if kaiin_id.present?
                unless torihiki_ids.include?(torihiki_id)
                  if kaiin_raitensu_hash[kaiin_id].present?
                    kaiin_raitensu_hash[kaiin_id] += 1
                  else
                    kaiin_raitensu_hash[kaiin_id] = 1
                  end
                end
              end
            else
              total_number_sales_sozai -= number if bumon_id == "1"
              hash[hinban][:sales_number] -= number
              hash[hinban][:total_sales_amount] -= nebikimaekei
              hash[hinban][:discount_amount] -= nebiki
              hash[hinban][:net_sales_amount] -= nebikigokei
              hash[hinban][:ex_tax_sales_amount] -= ex_tax_sales_amount
              hash[hinban][:delivery_sales_amount] -= delivery_sales_amount
              hash[hinban][:store_sales_amount] -= store_sales_amount
              hash[hinban][:tax_amount] -= tax_amount
              if Time.parse(time) < Time.parse('14:00')
                hash[hinban][:early_sales_number] -= number
                fourteen_number_sales_sozai -= number if bumon_id == "1"
                unless torihiki_ids.include?(torihiki_id)
                  fourteen_transaction_count -= 1
                end
              end

              # 会員情報の来店数更新
              if kaiin_id.present?
                unless torihiki_ids.include?(torihiki_id)
                  if kaiin_raitensu_hash[kaiin_id].present?
                    kaiin_raitensu_hash[kaiin_id] -= 1
                  else
                    kaiin_raitensu_hash[kaiin_id] = 0
                  end
                end
              end
            end
          end
          torihiki_ids << torihiki_id
        end
        store_id = analysis.store_id
        store_daily_menu = StoreDailyMenu.find_by(store_id:store_id,start_time:date)
        sdmd_hash = store_daily_menu.store_daily_menu_details.map{|sdmd|[sdmd.product_id,sdmd]}.to_h

        analysis_products_arr.each do |analysis_product|
          shohin_id = analysis_product.smaregi_shohin_id.to_s
          analysis_product.sales_number = hash[hinban][:sales_number]
          analysis_product.total_sales_amount = hash[hinban][:total_sales_amount]
          analysis_product.early_sales_number = hash[hinban][:early_sales_number]
          analysis_product.discount_amount = hash[hinban][:discount_amount]
          analysis_product.net_sales_amount = hash[hinban][:net_sales_amount]
          analysis_product.ex_tax_sales_amount = hash[hinban][:ex_tax_sales_amount]
          if analysis_product.total_sales_amount > 0
            analysis_product.discount_rate = (analysis_product.discount_amount/analysis_product.total_sales_amount).round(3)
          else
            analysis_product.discount_rate = 0
          end

          if hash[hinban][:early_sales_number] == 0
            analysis_product.potential = 0
          else
            analysis_product.potential = ((total_number_sales_sozai.to_f/fourteen_number_sales_sozai)*hash[hinban][:early_sales_number]).round(1)
          end

          if sdmd_hash[analysis_product.product_id].present?
            sdmd = sdmd_hash[analysis_product.product_id]
            analysis_product.cost_price = sdmd.product.cost_price
            analysis_product.orderecipe_sell_price = sdmd.product.sell_price
            analysis_product.manufacturing_number = sdmd.sozai_number
            analysis_product.carry_over = sdmd.carry_over
            analysis_product.actual_inventory = sdmd.actual_inventory
            analysis_product.loss_number = analysis_product.actual_inventory - analysis_product.sales_number
            if analysis_product.loss_number <= 0 ||analysis_product.loss_ignore==true
              analysis_product.loss_amount = 0
            else
              analysis_product.loss_amount = analysis_product.loss_number * analysis_product.orderecipe_sell_price
            end
            hash[hinban][:loss_amount] = analysis_product.loss_amount
          end
        end


        # 会員の来店数更新
        kaiin_ids = kaiin_raitensu_hash.keys
        orderecipe_saved_smaregi_members = SmaregiMember.where(kaiin_id:kaiin_ids)
        orderecipe_saved_smaregi_members.each do |sm|
          sm.raiten_kaisu = sm.raiten_kaisu + kaiin_raitensu_hash[sm.kaiin_id.to_s]
          sm.last_visit_store = date.to_date
          update_smaregi_members_arr << sm
        end
        total_sales_amount = hash.values.sum { |data| data[:total_sales_amount]}
        discount_amount = hash.values.sum { |data| data[:discount_amount]}
        net_sales_amount = hash.values.sum { |data| data[:net_sales_amount]}
        ex_tax_sales_amount = hash.values.sum { |data| data[:ex_tax_sales_amount]}
        tax_amount = hash.values.sum { |data| data[:tax_amount]}
        store_sales_amount = hash.values.sum { |data| data[:store_sales_amount]}
        delivery_sales_amount = hash.values.sum { |data| data[:delivery_sales_amount]}
        loss_amount = hash.values.sum { |data| data[:loss_amount]}
        analysis.update(total_sales_amount:total_sales_amount,transaction_count:transaction_count,fourteen_transaction_count:fourteen_transaction_count,
          total_number_sales_sozai:total_number_sales_sozai,fourteen_number_sales_sozai:fourteen_number_sales_sozai,discount_amount:discount_amount,loss_amount:loss_amount,
          net_sales_amount:net_sales_amount,tax_amount:tax_amount,ex_tax_sales_amount:ex_tax_sales_amount,store_sales_amount:store_sales_amount,delivery_sales_amount:delivery_sales_amount)
        SmaregiTradingHistory.import smaregi_trading_histories_arr
        AnalysisProduct.import analysis_products_arr
        SmaregiMember.import update_smaregi_members_arr, on_duplicate_key_update:[:raiten_kaisu,:last_visit_store]
      end
    end
    return (2)
  end

  def self.oncerecalculate(from,to,store_id)
    analyses = Analysis.where(date:from..to).where(store_id:store_id)
    analyses.each do |analysis|
      sleep(1)
      recalculate(analysis.id)
    end
  end


  def self.recalculate(analysis_id)
    analysis = Analysis.find(analysis_id)
    date = analysis.date
    analysis.analysis_products.destroy_all if analysis.analysis_products
    number = 0
    analysis_total_sales_amount = 0
    analysis_discount_amount = 0
    analysis_net_sales_amount = 0
    analysis_ex_tax_sales_amount = 0
    analysis_tax_amount = 0
    analysis_store_sales_amount = 0
    analysis_delivery_sales_amount = 0
    analysis_used_point_amount = 0
    torihiki_ids = []
    fourteen_transaction_count = 0
    transaction_count = 0
    total_sales = 0
    total_early_sales_number = 0
    total_number_sales_sozai = 0
    fourteen_number_sales_sozai = 0
    smaregi_trading_histories_arr = []
    analysis_products_arr = []
    update_analysis_products_arr = []
    hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    product_sales_number = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    product_early_sales_number = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    product_sales_amount = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    analysis = Analysis.find(analysis_id)
    product_ids = []
    kaiin_raitensu_hash = {}
    update_smaregi_members_arr = []

    SmaregiTradingHistory.where(analysis_id:analysis_id).each do |smaregi_trading_history|
      torihiki_id = smaregi_trading_history.torihiki_id
      shohinmei = smaregi_trading_history.shohinmei
      tanka_nebikimae_shokei = smaregi_trading_history.tanka_nebikimae_shokei.to_i
      tanka_nebiki_shokei = smaregi_trading_history.tanka_nebiki_shokei.to_i
      shokei = smaregi_trading_history.shokei.to_i
      shikei_nebiki = smaregi_trading_history.shikei_nebiki.to_i
      point_nebiki = smaregi_trading_history.point_nebiki.to_i
      gokei = smaregi_trading_history.gokei.to_i
      tenpo_id = smaregi_trading_history.tenpo_id
      torihiki_meisaikubun = smaregi_trading_history.torihiki_meisaikubun
      shohin_id = smaregi_trading_history.shohin_id
      hinban = smaregi_trading_history.hinban
      shohintanka = smaregi_trading_history.shohintanka.to_i
      tanka_nebikikei = smaregi_trading_history.tanka_nebikikei.to_i
      suryo = smaregi_trading_history.suryo.to_i
      nebikigokei = smaregi_trading_history.nebikigokei.to_i
      time = "#{smaregi_trading_history.time.hour}:#{smaregi_trading_history.time.min}"
      shiharaihouhou = smaregi_trading_history.shiharaihouhou
      bumonmei = smaregi_trading_history.bumonmei
      bumon_id = smaregi_trading_history.bumon_id
      nebikimaekei = smaregi_trading_history.nebikimaekei.to_i
      uchishohizei = smaregi_trading_history.uchishohizei.to_i
      uchizeianbun = smaregi_trading_history.uchizeianbun.to_i
      tanpin_waribiki = smaregi_trading_history.tanpin_waribiki
      product_zeinuki_uriage = nebikigokei - uchizeianbun
      if hinban == 10459 ||hinban == 12899 ||hinban == 13179 ||hinban == 14099
        loss_ignore = true
      else
        loss_ignore = false
      end
      if product_ids.include?(hinban)
        if hash[hinban][:smaregi_shohin_id].include?(shohin_id)
        else
          hash[hinban][:smaregi_shohin_id] << shohin_id
          hash[hinban][:smaregi_price] = "#{hash[hinban][:smaregi_price]},#{shohintanka}"
          hash[hinban][:smaregi_shohin_name] = "#{hash[hinban][:smaregi_shohin_name]},#{shohinmei}"
        end
      else
        new_analysis_product = AnalysisProduct.new(analysis_id:analysis_id,smaregi_shohin_id:shohin_id,smaregi_shohin_name:shohinmei,smaregi_shohintanka:shohintanka,
        product_id:hinban,total_sales_amount:0,sales_number:0,loss_amount:0,early_sales_number:0,bumon_id:bumon_id,bumon_mei:bumonmei,
        discount_amount:0,net_sales_amount:0,ex_tax_sales_amount:0,discount_rate:0,loss_ignore:loss_ignore,discount_number:0)
        analysis_products_arr << new_analysis_product
        product_ids << hinban
        hash[hinban]={sales_number:0,total_sales_amount:0,discount_amount:0,net_sales_amount:0,ex_tax_sales_amount:0,early_sales_number:0,loss_amount:0,smaregi_shohin_id:[shohin_id],smaregi_shohin_name:shohinmei,smaregi_price:shohintanka,discount_number:0}
      end
      # ▼analysis_productの更新部分
      if torihiki_meisaikubun == 1 ||torihiki_meisaikubun == 3
        transaction_count += 1 unless torihiki_ids.include?(torihiki_id)
        total_number_sales_sozai += suryo if bumon_id == 1
        hash[hinban][:sales_number] += suryo
        hash[hinban][:total_sales_amount] += nebikimaekei
        hash[hinban][:discount_amount] += tanka_nebikikei
        hash[hinban][:net_sales_amount] += nebikigokei
        hash[hinban][:ex_tax_sales_amount] += product_zeinuki_uriage
        if tanpin_waribiki.present?
          hash[hinban][:discount_number] += suryo
        end
        if Time.parse(time) < Time.parse('14:00')
          hash[hinban][:early_sales_number] += suryo
          fourteen_number_sales_sozai += suryo if bumon_id == 1
          fourteen_transaction_count += 1 unless torihiki_ids.include?(torihiki_id)
        end
      elsif torihiki_meisaikubun == 2
        transaction_count -= 1 unless torihiki_ids.include?(torihiki_id)
        total_number_sales_sozai -= suryo if bumon_id == 1
        hash[hinban][:sales_number] -= suryo
        hash[hinban][:total_sales_amount] -= nebikimaekei
        hash[hinban][:discount_amount] -= tanka_nebikikei
        hash[hinban][:net_sales_amount] -= nebikigokei
        hash[hinban][:ex_tax_sales_amount] -= product_zeinuki_uriage
        if tanpin_waribiki.present?
          hash[hinban][:discount_number] -= suryo
        end
        if Time.parse(time) < Time.parse('14:00')
          hash[hinban][:early_sales_number] -= suryo
          fourteen_number_sales_sozai -= suryo if bumon_id == 1
          fourteen_transaction_count -= 1 unless torihiki_ids.include?(torihiki_id)
        end
      end
      # ▼analysisの更新部分
      unless torihiki_ids.include?(torihiki_id)
        tanka_nebikimae_shokei = tanka_nebikimae_shokei #総売上
        nebiki = tanka_nebiki_shokei + shikei_nebiki
        used_point_amount = point_nebiki.to_i
        gokei = gokei #純売上
        ex_tax_sales_amount = gokei - uchishohizei #税抜売上
        if shiharaihouhou == 3
          delivery_sales_amount = ex_tax_sales_amount
          store_sales_amount = 0
        else
          delivery_sales_amount = 0
          store_sales_amount = ex_tax_sales_amount
        end
        torihiki_ids << torihiki_id
        # analysisの更新はtorihikimeisaikubunは関係ない（商品データのみ影響する ）
        # https://docs.google.com/spreadsheets/d/1GLrC1AoE86bIlr3gpJlcthnA8zsB-KpbtoM4dSoKrng/edit#gid=245604921
        analysis_total_sales_amount += tanka_nebikimae_shokei
        analysis_discount_amount += nebiki
        analysis_net_sales_amount += gokei
        analysis_ex_tax_sales_amount += ex_tax_sales_amount
        analysis_tax_amount += uchishohizei
        analysis_store_sales_amount += store_sales_amount
        analysis_delivery_sales_amount += delivery_sales_amount
        analysis_used_point_amount += used_point_amount
      end
    end

    store_id = analysis.store_id
    store_daily_menu = StoreDailyMenu.find_by(store_id:store_id,start_time:date)
    sdmd_hash = store_daily_menu.store_daily_menu_details.map{|sdmd|[sdmd.product_id,sdmd]}.to_h
    analysis_products_arr.each do |analysis_product|
      product_id = analysis_product.product_id
      analysis_product.smaregi_shohin_name = hash[product_id][:smaregi_shohin_name]
      analysis_product.sales_number = hash[product_id][:sales_number]
      analysis_product.total_sales_amount = hash[product_id][:total_sales_amount]
      analysis_product.early_sales_number = hash[product_id][:early_sales_number]
      analysis_product.discount_amount = hash[product_id][:discount_amount]
      analysis_product.net_sales_amount = hash[product_id][:net_sales_amount]
      analysis_product.ex_tax_sales_amount = hash[product_id][:ex_tax_sales_amount]
      analysis_product.discount_number = hash[product_id][:discount_number]
      if analysis_product.total_sales_amount.present? && analysis_product.total_sales_amount > 0
        analysis_product.discount_rate = (analysis_product.discount_amount/analysis_product.total_sales_amount).round(3)
      else
        analysis_product.discount_rate = 0
      end

      if hash[product_id][:early_sales_number] == 0
        analysis_product.potential = 0
      else
        analysis_product.potential = ((total_number_sales_sozai.to_f/fourteen_number_sales_sozai)*hash[product_id][:early_sales_number]).round(1)
      end

      if sdmd_hash[analysis_product.product_id].present?
        sdmd = sdmd_hash[analysis_product.product_id]
        analysis_product.cost_price = sdmd.product.cost_price
        analysis_product.orderecipe_sell_price = sdmd.product.sell_price
        analysis_product.manufacturing_number = sdmd.sozai_number
        analysis_product.carry_over = sdmd.carry_over
        analysis_product.actual_inventory = sdmd.actual_inventory
        analysis_product.loss_number = analysis_product.actual_inventory - analysis_product.sales_number
        if analysis_product.loss_number <= 0 ||analysis_product.loss_ignore==true
          analysis_product.loss_amount = 0
        else
          analysis_product.loss_amount = analysis_product.loss_number * analysis_product.orderecipe_sell_price
        end
        hash[product_id][:loss_amount] = analysis_product.loss_amount
      end
    end
    loss_amount = hash.values.sum { |data| data[:loss_amount]}
    analysis.update(total_sales_amount:analysis_total_sales_amount,transaction_count:transaction_count,fourteen_transaction_count:fourteen_transaction_count,
      total_number_sales_sozai:total_number_sales_sozai,fourteen_number_sales_sozai:fourteen_number_sales_sozai,discount_amount:analysis_discount_amount,loss_amount:loss_amount,
      net_sales_amount:analysis_net_sales_amount,tax_amount:analysis_tax_amount,ex_tax_sales_amount:analysis_ex_tax_sales_amount,store_sales_amount:analysis_store_sales_amount,
      delivery_sales_amount:analysis_delivery_sales_amount,used_point_amount:analysis_used_point_amount)
    AnalysisProduct.import analysis_products_arr
    # SmaregiMember.import update_smaregi_members_arr, on_duplicate_key_update:[:raiten_kaisu,:last_visit_store]
    return (smaregi_trading_histories_arr.count)
  end








  def self.upload_data(form_date,smaregi_store_id,analysis_id,file)
    smaregi_trading_histories_arr = []
    CSV.foreach file.path, {encoding: 'BOM|UTF-8', headers: true} do |row|
      row = row.to_hash
      torihiki_id = row["取引ID"]
      torihiki_nichiji = row["取引日時"]
      date = torihiki_nichiji.to_date
      tanka_nebikimae_shokei = row["単価値引き前小計"]
      tanka_nebiki_shokei = row["単価値引き小計"]
      shokei = row["小計"]
      shikei_nebiki = row["小計値引き"]
      shokei_waribikiritsu = row["小計割引率"]
      point_nebiki = row["ポイント値引き"]
      gokei = row["合計"]
      suryo_gokei = row["数量合計"]
      henpinsuryo_gokei = row["返品数量合計"]
      huyo_point = row["付与ポイント"]
      shiyo_point = row["使用ポイント"]
      genzai_point = row["現在ポイント"]
      gokei_point = row["合計ポイント"]
      tenpo_id = row["店舗ID"]
      kaiin_id = row["会員ID"]
      kaiin_code = row["会員コード"]
      tanmatsu_torihiki_id = row["端末取引ID"]
      nenreiso = row["年齢層"]
      kyakuso_id = row["客層ID"]
      hanbaiin_id = row["販売員ID"]
      hanbaiin_mei = row["販売員名"]
      torihikimeisai_id = row["取引明細ID"]
      torihiki_meisaikubun = row["取引明細区分 （1：通常、2：返品、3：部門売り）"]
      shohin_id = row["商品ID"]
      shohin_code = row["商品コード"]
      hinban = row["品番"]
      shohinmei = row["商品名"]
      shohintanka = row["商品単価"]
      hanbai_tanka = row["販売単価"]
      tanpin_nebiki = row["単品値引"]
      tanpin_waribiki = row["単品割引"]
      suryo = row["数量"]
      nebikimaekei = row["値引き前計"]
      tanka_nebikikei = row["単価値引き計"]
      nebikigokei = row["値引き後計"]
      bumon_id = row["部門ID"]
      bumonmei = row["部門名"]
      time = "#{Time.parse(torihiki_nichiji).hour}:#{Time.parse(torihiki_nichiji).min}"
      uchikeshi_torihiki_id = row["打消取引ID"]
      uchikeshi_kubun = row["打消区分(0：通常、1：打消元レコード、2：打消レコード)"]
      receipt_number = row["レシート番号"]
      shiharaihouhou = row["支払方法ID1"]
      uchishohizei = row["内消費税"]
      uchizeianbun = row["内税按分"]
      zeinuki_uriage = nebikigokei.to_i - uchizeianbun.to_i
      if date == form_date.to_date && smaregi_store_id == tenpo_id
        new_smaregi_trading_history = SmaregiTradingHistory.new(date:date,analysis_id:analysis_id,torihiki_id:torihiki_id,torihiki_nichiji:torihiki_nichiji,tanka_nebikimae_shokei:tanka_nebikimae_shokei,
          tanka_nebiki_shokei:tanka_nebiki_shokei,shokei:shokei,shikei_nebiki:shikei_nebiki,shokei_waribikiritsu:shokei_waribikiritsu,
          point_nebiki:point_nebiki,gokei:gokei,suryo_gokei:suryo_gokei,henpinsuryo_gokei:henpinsuryo_gokei,huyo_point:huyo_point,
          shiyo_point:shiyo_point,genzai_point:genzai_point,gokei_point:gokei_point,tenpo_id:tenpo_id,kaiin_id:kaiin_id,kaiin_code:kaiin_code,
          tanmatsu_torihiki_id:tanmatsu_torihiki_id,nenreiso:nenreiso,kyakuso_id:kyakuso_id,hanbaiin_id:hanbaiin_id,hanbaiin_mei:hanbaiin_mei,
          torihikimeisai_id:torihikimeisai_id,torihiki_meisaikubun:torihiki_meisaikubun,shohin_id:shohin_id,shohin_code:shohin_code,
          hinban:hinban,shohinmei:shohinmei,shohintanka:shohintanka,hanbai_tanka:hanbai_tanka,tanpin_nebiki:tanpin_nebiki,tanpin_waribiki:tanpin_waribiki,
          suryo:suryo,nebikimaekei:nebikimaekei,tanka_nebikikei:tanka_nebikikei,nebikigokei:nebikigokei,bumon_id:bumon_id,bumonmei:bumonmei,time:time,
          uchikeshi_torihiki_id:uchikeshi_torihiki_id,uchikeshi_kubun:uchikeshi_kubun,receipt_number:receipt_number,shiharaihouhou:shiharaihouhou,
          uchishohizei:uchishohizei,uchizeianbun:uchizeianbun,zeinuki_uriage:zeinuki_uriage)
        smaregi_trading_histories_arr << new_smaregi_trading_history
      end
    end
    SmaregiTradingHistory.import smaregi_trading_histories_arr
    return (smaregi_trading_histories_arr.count)
  end
end
