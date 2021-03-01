class Stock < ApplicationRecord
  belongs_to :material

  # 棚卸しをcsv等で一括アップデートしたときに、それ以降の在庫を動かす処理
  def self.csv_stocks_update
    update_stocks = []

    stock_ids = [
      913799,913839,913909,914059,914079,914089,914129,914149,914169,914239,914249,914309,914319,914339,914429,914469,914509,914699,914719,914729,
      914749,914889,914919,914929,915269,918459,918469,918479,919519,919529,919889,919969,919989,920199,922999,923009,902879,902889,903039,903129,
      903279,903299,908009,915579,915589,915689,915849,918489,919629,922109,922269,924329,924339,925519,925709,925809,925899,926109,881149,881159,
      881219,881249,881349,881359,881449,887499,887539,887559,887619,887639,887649,887739,887749,887769,887779,887789,887859,887899,887909,908889,
      908899,908939,908989,917199,917289,917369,917409,917449,917459,917479,917489,919569,923819,923849,923869,925119,925179,925199,925219,925229,
      925239,925309,925319,925429,926249,926259,926329,926369,926449,926529,926539,926569,926649,926789,926809,926819,926839,930489,930499,930509,
      930769,932709,932719,933589,933599,933609,933619,933629,933639,933649,933659,933669,933679,933689,933699,926899,926949,926969,927419,927539,
      927629,927639,927649,927759,927799,927989,928069,928109,932169,932179,932199,932209,932219,932229
    ]
    stock_ids.each do |stock_id|
      stock = Stock.find(stock_id)
      change_stock(update_stocks,stock.material_id,stock.date,stock.end_day_stock)
    end


    # material_ids = [
    #   11,5951,12102,23791,19921,12331,22171,3201,12741,15041,2111,461,4021,41,121,241,11571,331,13251,91,11321,26191,351,18311,
    #   11581,4761,7031,26161,15291,15301,10071,18471,20561,1311,26181,26271,17541,9031,18571,19051,25441,2581,2991,4871,14181,13091,
    #   15891,26151,2611,16441,11911,17001,4911,23691,25371,5221,25871,26389,10231,10241,15811,21291,3901,3921,3941,16661,20751,3991,
    #   21551,23221,7531,19691,20001,10361,291,10041,18131,9141,18441,16281,16311,18341,16231,14891,11471,3951,8761,26011,22611,21621,19251,
    #   18651,861,18161,3911,20721,2121,361,11631,481,391,491,8721,1081,871,24451,23441,6251,13151,25221,25231,25741,10601,26639,2441,12831,
    #   10561,26281,26291,26301,14881,26499,26509,24341,24351,25941,25931,25731,25721,25961,25951,25151,25141,26141,26131,4571,1271,901,12891,
    #   141,25561,20771,25321,25981,3271,16101,25811,4031,4631,11331,15971,16331,16401,17151
    # ]
    # date = Date.new(2020,12,29)
    # material_ids.each do |material_id|
    #   stock = Stock.find_by(date:date,material_id:material_id)
    #   change_stock(update_stocks,material_id,date,stock.end_day_stock)
    # end


    Stock.import update_stocks, on_duplicate_key_update:[:end_day_stock,:start_day_stock,:inventory_flag] if update_stocks.present?
  end


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
