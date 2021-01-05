class Stock < ApplicationRecord
  belongs_to :material

  # 棚卸しをcsv等で一括アップデートしたときに、それ以降の在庫を動かす処理
  # def self.csv_stocks_update
  #   update_stocks = []
  #   material_ids = [19351,19421,19751,21891,21151,19631,24581,22751,23571,24181,25401,20021,23691,23511,3081,3171,2781,2611,2581,15891,
  #     10951,14931,15261,14021,14981,16511,2991,3041,2981,9031,19051,10301,14181,15041,17611,17861,3271,3201,18151,14881,
  #     14891,18161,25031,24671,25061,24791,19291,17911,23541,16281,16311,18441,18431,12601,17001,18571,25371,18321,4871,
  #     4911,16441,5061,10241,10231,7531,17541,25441,17921,5271,5291,14521,22341,15451,12151,7131,11911,11851,15011,7361,
  #     7031,6911,11261,11241,17831,13111,11421,2151,17621,12831,15771,20041,16331,15081,18291,14801,14961,11251,2101,11,
  #     11321,10041,331,10361,16661,11471,461,10891,291,11571,41,13611,16821,16231,421,12411,11581,14821,8751,15971,541,17591,
  #     661,631,91,2011,25351,9261,2041,12301,2111,16101,861,20981,51,23791,18131,19921,25811,13151,17181,1081,11331,21291,
  #     141,361,22171,821,19881,4201,12102,10091,13591,4521,20291,10481,20001,4021,13401,13081,4001,4741,3891,4271,9141,12711,
  #     10101,3911,3951,3901,10601,3821,4571,3941,3921]
  #   date = Date.new(2020,12,29)
  #   material_ids.each do |material_id|
  #     stock = Stock.find_by(date:date,material_id:material_id)
  #     change_stock(update_stocks,material_id,date,stock.end_day_stock)
  #   end
  #   Stock.import update_stocks, on_duplicate_key_update:[:end_day_stock,:start_day_stock,:inventory_flag] if update_stocks.present?
  # end


  def self.calculate_stock(date,previous_day)
    @hash = {}
    new_stocks = []
    update_stocks = []

    #dateの対象となるstockのused_amountを一旦0に
    initialize_stocks(previous_day)
    #dateの対象となる、kurumesi_orderとdaily_menuかつ、fixしているものを、product_idと製造数を配列で習得
    date_manufacturing_products(date)
    #全部の弁当と製造数をeachでまわして、materialのuniqと使用量のハッシュ形式にする
    self.calculate_date_all_material_used_amount()
    #materialのハッシュをまわしていく、このとき単位の変換を行なう。dateとmaterialに対応するstockがすでにあれば更新の配列に、なければ新規の配列にぶちこみ、最後にbulk_insertで終了
    @hash.each do |data|
      material_id = data[0]
      material = Material.find(material_id)
      used_amount = data[1]
      #すでにstockのobjectがあるかどうか？
      stock = Stock.find_by(date:previous_day,material_id:material_id)
      if stock
        stock.used_amount = used_amount
        end_day_stock = stock.start_day_stock - used_amount + stock.delivery_amount
        stock.end_day_stock = end_day_stock
        update_stocks << stock
        change_stock(update_stocks,material_id,previous_day,end_day_stock)
      else
        prev_stock = Stock.where("date < ?", previous_day).where(material_id:material_id).order("date DESC").first
        if prev_stock.present?
          end_day_stock = prev_stock.end_day_stock - used_amount
          new_stocks << Stock.new(material_id:material_id,date:previous_day,used_amount:used_amount,end_day_stock:end_day_stock,start_day_stock:prev_stock.end_day_stock)
        else
          end_day_stock = 0 - used_amount
          new_stocks << Stock.new(material_id:material_id,date:previous_day,used_amount:used_amount,end_day_stock:end_day_stock)
        end
        change_stock(update_stocks,material_id,previous_day,end_day_stock)
      end
    end
    Stock.import new_stocks if new_stocks.present?
    Stock.import update_stocks, on_duplicate_key_update:[:used_amount,:end_day_stock,:start_day_stock] if update_stocks.present?
  end

  def self.initialize_stocks(previous_day)
    stocks = Stock.where(date:previous_day)
    stocks.update_all(used_amount:0)
  end

  def self.date_manufacturing_products(date)
    kurumesi_order_products = KurumesiOrderDetail.joins(:kurumesi_order).where(:kurumesi_orders => {start_time:date,canceled_flag:false}).group('product_id').sum(:number).to_a
    shogun_order_products = DailyMenuDetail.joins(:daily_menu).where(:daily_menus => {start_time:date,fixed_flag:true}).group('product_id').sum(:manufacturing_number).to_a
    @product_manufacturing = kurumesi_order_products + shogun_order_products
  end

  def self.calculate_date_all_material_used_amount
    @product_manufacturing.each do |pm|
      product = Product.find(pm[0])
      menu_ids = product.menus.ids
      menu_materials = MenuMaterial.where(menu_id:menu_ids)
      menu_materials.each do |mm|
        if @hash[mm.material_id]
          @hash[mm.material_id] += mm.amount_used * pm[1]
        else
          @hash[mm.material_id] = mm.amount_used * pm[1]
        end
      end
    end
  end

  #未来の在庫を書き換えていく処理
  def self.change_stock(update_stocks,material_id,previous_day,end_day_stock)
    stocks = Stock.where(material_id:material_id).where('date > ?', previous_day).where(inventory_flag:true)
    if stocks.present?
      #date以降で棚卸ししてたら、在庫を動かす処理はとくになし
    else
      date_later_stocks = Stock.where(material_id:material_id).where('date > ?', previous_day).order('date ASC')
      date_later_stocks.each_with_index do |dls,i|
        dls.start_day_stock = end_day_stock
        dls.end_day_stock = dls.start_day_stock - dls.used_amount + dls.delivery_amount
        end_day_stock = dls.end_day_stock
        update_stocks << dls
      end
    end
  end

  def self.stock_status_check
    materials_arr = []
    today = Date.today
    all_material_ids = Stock.where('date <= ?',today).pluck("material_id").uniq
    materials = Material.where(id:all_material_ids)
    stocks = Stock.order("date DESC").where('date <= ?',today)
    materials.each do |material|
      latest_stock = stocks.find_by(material_id:material.id)
      last_inventory = stocks.find_by(material_id:material.id,inventory_flag:true)
      if material.stock_management_flag == true
        if last_inventory.present?
          material.last_inventory_date = last_inventory.date
          if latest_stock.inventory_flag == true && latest_stock.end_day_stock == 0
            material.need_inventory_flag = false
          else
            if today - last_inventory.date < 30
              material.need_inventory_flag = false
            else
              material.need_inventory_flag = true
            end
          end
        else
          material.need_inventory_flag = true
        end
      else
        material.need_inventory_flag = false
      end
      materials_arr << material
    end
    Material.import materials_arr, on_duplicate_key_update: [:last_inventory_date,:need_inventory_flag]
  end
end
