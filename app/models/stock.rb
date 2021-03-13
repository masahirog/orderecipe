class Stock < ApplicationRecord
  belongs_to :material

  # 棚卸しをcsv等で一括アップデートしたときに、それ以降の在庫を動かす処理
  # def self.csv_stocks_update
  #   update_stocks = []
  #
  #   # stock_ids = [
  #   #   913799,913839,913909,914059,914079,914089,914129,914149,914169,914239,914249,914309,914319,914339,914429,914469,914509,914699,914719,914729,
  #   #   914749,914889,914919,914929,915269,918459,918469,918479,919519,919529,919889,919969,919989,920199,922999,923009,902879,902889,903039,903129,
  #   #   903279,903299,908009,915579,915589,915689,915849,918489,919629,922109,922269,924329,924339,925519,925709,925809,925899,926109,881149,881159,
  #   #   881219,881249,881349,881359,881449,887499,887539,887559,887619,887639,887649,887739,887749,887769,887779,887789,887859,887899,887909,908889,
  #   #   908899,908939,908989,917199,917289,917369,917409,917449,917459,917479,917489,919569,923819,923849,923869,925119,925179,925199,925219,925229,
  #   #   925239,925309,925319,925429,926249,926259,926329,926369,926449,926529,926539,926569,926649,926789,926809,926819,926839,930489,930499,930509,
  #   #   930769,932709,932719,933589,933599,933609,933619,933629,933639,933649,933659,933669,933679,933689,933699,926899,926949,926969,927419,927539,
  #   #   927629,927639,927649,927759,927799,927989,928069,928109,932169,932179,932199,932209,932219,932229
  #   # ]
  #   # stock_ids.each do |stock_id|
  #   #   stock = Stock.find(stock_id)
  #   #   change_stock(update_stocks,stock.material_id,stock.date,stock.end_day_stock)
  #   # end
  #
  #   material_ids = [
  #     [26559,"2021/02/22"],[17861,"2021/02/22"],[3131,"2021/02/22"],[15311,"2021/02/22"],[18171,"2021/02/22"],[17921,"2021/02/22"],[16061,"2021/02/22"],[5411,"2021/02/22"],[9631,"2021/02/22"],
  #     [6891,"2021/02/22"],[7361,"2021/02/22"],[8841,"2021/02/22"],[15011,"2021/02/22"],[6861,"2021/02/22"],[7241,"2021/02/22"],[13071,"2021/02/22"],[12751,"2021/02/22"],[6911,"2021/02/22"],
  #     [6721,"2021/02/22"],[6641,"2021/02/22"],[22521,"2021/02/22"],[7371,"2021/02/22"],[11931,"2021/02/22"],[18861,"2021/02/22"],[12771,"2021/02/22"],[8731,"2021/02/22"],[541,"2021/02/22"],
  #     [24391,"2021/02/22"],[15941,"2021/02/22"],[15281,"2021/02/22"],[12411,"2021/02/22"],[12301,"2021/02/22"],[15111,"2021/02/22"],[25641,"2021/02/22"],[15871,"2021/02/22"],[15781,"2021/02/22"],
  #     [13661,"2021/02/22"],[651,"2021/02/22"],[921,"2021/02/22"],[51,"2021/02/22"],[18401,"2021/02/22"],[671,"2021/02/22"],[451,"2021/02/22"],[25261,"2021/02/22"],[13611,"2021/02/22"],
  #     [61,"2021/02/22"],[13111,"2021/02/22"],[25361,"2021/02/22"],[25581,"2021/02/22"],[20961,"2021/02/22"],[11672,"2021/02/22"],[1631,"2021/02/22"],[10781,"2021/02/22"],[11091,"2021/02/22"],
  #     [10841,"2021/02/22"],[15341,"2021/02/22"],[13651,"2021/02/22"],[471,"2021/02/22"],[12221,"2021/02/22"],[981,"2021/02/22"],[941,"2021/02/22"],[20931,"2021/02/22"],[661,"2021/02/22"],
  #     [2101,"2021/02/22"],[20941,"2021/02/22"],[421,"2021/02/22"],[9261,"2021/02/22"],[2041,"2021/02/22"],[11311,"2021/02/22"],[631,"2021/02/22"],[21,"2021/02/22"],[16421,"2021/02/22"],
  #     [13401,"2021/02/22"],[4721,"2021/02/22"],[13081,"2021/02/22"],[3891,"2021/02/22"],[10321,"2021/02/22"],[4001,"2021/02/22"],[11601,"2021/02/22"],[10341,"2021/02/22"],[23731,"2021/02/22"],
  #     [19631,"2021/02/24"],[18961,"2021/02/24"],[25401,"2021/02/24"],[16511,"2021/02/24"],[18331,"2021/02/24"],[23001,"2021/02/24"],[4961,"2021/02/24"],[17601,"2021/02/24"],[18321,"2021/02/24"],
  #     [12601,"2021/02/24"],[5061,"2021/02/24"],[25651,"2021/02/24"],[24111,"2021/02/24"],[4921,"2021/02/24"],[5101,"2021/02/24"],[11621,"2021/02/24"],[4931,"2021/02/24"],[5091,"2021/02/24"],
  #     [4991,"2021/02/24"],[26041,"2021/02/24"],[18211,"2021/02/24"],[26379,"2021/02/24"],[22191,"2021/02/24"],[18301,"2021/02/25"],[821,"2021/02/25"],[1901,"2021/02/25"],[18481,"2021/02/25"],
  #     [17191,"2021/02/25"],[1071,"2021/02/25"],[20981,"2021/02/25"],[131,"2021/02/25"],[20781,"2021/02/25"],[2531,"2021/02/25"],[381,"2021/02/25"],[10531,"2021/02/25"],[171,"2021/02/25"],
  #     [2011,"2021/02/25"],[24411,"2021/02/25"],[26359,"2021/02/25"],[811,"2021/02/25"],[24421,"2021/02/25"],[25341,"2021/02/25"],[231,"2021/02/25"],[10521,"2021/02/25"],[23551,"2021/02/25"],
  #     [16501,"2021/02/25"],[2241,"2021/02/25"],[25311,"2021/02/25"],[2261,"2021/02/25"],[1091,"2021/02/25"],[25251,"2021/02/25"],[2221,"2021/02/25"],[8921,"2021/02/25"],[23931,"2021/02/25"],
  #     [11461,"2021/02/25"],[9071,"2021/02/25"],[2231,"2021/02/25"],[31,"2021/02/25"],[1721,"2021/02/25"],[9001,"2021/02/25"],[12661,"2021/02/25"],[9121,"2021/02/25"],[4741,"2021/02/25"],
  #     [10141,"2021/02/25"],[3971,"2021/02/25"],[3881,"2021/02/25"],[9301,"2021/02/25"],[10971,"2021/02/25"],[4491,"2021/02/25"],[10031,"2021/02/25"],[19651,"2021/02/25"],[19661,"2021/02/25"],
  #     [23621,"2021/02/25"],[8061,"2021/02/25"],[23911,"2021/02/25"],[19491,"2021/02/25"],[19471,"2021/02/25"],[7521,"2021/02/25"],[8681,"2021/02/25"],[11071,"2021/02/25"],[25501,"2021/02/25"],
  #     [20711,"2021/02/25"],[7541,"2021/02/25"],[7991,"2021/02/25"],[25551,"2021/02/25"],[21031,"2021/02/25"],[23901,"2021/02/25"],[7891,"2021/02/25"],[8321,"2021/02/25"],[25631,"2021/02/25"],
  #     [24091,"2021/02/25"],[7931,"2021/02/25"],[26101,"2021/02/25"],[11081,"2021/02/25"],[18381,"2021/02/25"],[21691,"2021/02/25"],[25691,"2021/02/25"],[26479,"2021/02/25"],[21051,"2021/02/25"],
  #     [21381,"2021/02/25"],[25511,"2021/02/25"],[23891,"2021/02/25"],[21401,"2021/02/25"],[25621,"2021/02/25"],[25701,"2021/02/25"],[8661,"2021/02/25"],[20701,"2021/02/25"],[8651,"2021/02/25"],
  #     [25571,"2021/02/25"],[25711,"2021/02/25"],[25541,"2021/02/25"],[18151,"2021/02/25"],[25201,"2021/02/25"],[18431,"2021/02/25"],[25121,"2021/02/25"],[15711,"2021/02/25"],[15701,"2021/02/25"],
  #     [16251,"2021/02/25"],[25211,"2021/02/25"],[16261,"2021/02/25"],[25381,"2021/02/25"],[16271,"2021/02/25"],[25421,"2021/02/25"],[26529,"2021/02/25"],[25411,"2021/02/25"],[26599,"2021/02/25"],
  #     [10891,"2021/02/26"],[17091,"2021/02/26"],[25351,"2021/02/26"],[19281,"2021/02/26"],[71,"2021/02/26"],[101,"2021/02/26"],[11411,"2021/02/26"],[20121,"2021/02/26"],[22951,"2021/02/26"],
  #     [11041,"2021/02/26"],[11651,"2021/02/26"],[10051,"2021/02/26"],[22961,"2021/02/26"],[681,"2021/02/26"],[26021,"2021/02/26"],[26319,"2021/02/26"],[10661,"2021/02/26"],[23951,"2021/02/26"],
  #     [18091,"2021/02/26"],[2071,"2021/02/26"],[26339,"2021/02/26"],[1341,"2021/02/26"],[11531,"2021/02/26"],[3831,"2021/02/26"],[10571,"2021/02/26"],[12941,"2021/02/26"],[10921,"2021/02/26"],
  #     [4751,"2021/02/26"],[16821,"2021/02/26"],[1731,"2021/02/26"],[22571,"2021/02/26"],[15171,"2021/02/26"],[12651,"2021/02/26"],[17131,"2021/02/26"],[10011,"2021/02/26"],[26449,"2021/02/26"],
  #     [26419,"2021/02/26"],[26429,"2021/02/26"],[19801,"2021/02/26"],[19771,"2021/02/26"],[19751,"2021/02/26"],[20021,"2021/02/26"],[22751,"2021/02/26"],[24071,"2021/02/26"],[19561,"2021/02/26"],
  #     [19521,"2021/02/26"],[20151,"2021/02/26"],[19871,"2021/02/26"],[19601,"2021/02/26"],[21191,"2021/02/26"],[24181,"2021/02/26"],[22391,"2021/02/26"],[10301,"2021/02/26"],[17611,"2021/02/26"],
  #     [3041,"2021/02/26"],[14931,"2021/02/26"],[2981,"2021/02/26"],[14621,"2021/02/26"],[11151,"2021/02/26"],[17301,"2021/02/26"],[11851,"2021/02/26"],[16081,"2021/02/26"],[21981,"2021/02/26"],
  #     [18291,"2021/02/26"],[15081,"2021/02/26"],[14961,"2021/02/26"],[14821,"2021/02/26"],[11281,"2021/02/26"],[17181,"2021/02/26"],[24141,"2021/02/26"],[14801,"2021/02/26"],[11251,"2021/02/26"],
  #     [17621,"2021/02/26"],[17591,"2021/02/26"],[17851,"2021/02/26"],[15371,"2021/02/26"],[11241,"2021/02/26"],[23281,"2021/02/26"],[17941,"2021/02/26"],[11261,"2021/02/26"],[26231,"2021/02/26"],
  #     [11421,"2021/02/26"],[18061,"2021/02/26"],[1411,"2021/02/26"],[12501,"2021/02/26"],[3691,"2021/02/26"],[4381,"2021/02/26"],[13591,"2021/02/26"],[19431,"2021/02/26"],[26001,"2021/02/26"],
  #     [12711,"2021/02/26"],[4311,"2021/02/26"],[17821,"2021/02/26"],[4271,"2021/02/26"],[19681,"2021/02/28"],[10931,"2021/02/28"],[10091,"2021/02/28"],[4511,"2021/02/28"],[10941,"2021/02/28"]
  #   ]
  #   material_ids.each do |material_id_and_date|
  #     material_id = material_id_and_date[0]
  #     date = material_id_and_date[1]
  #     stock = Stock.find_by(date:date,material_id:material_id)
  #     change_stock(update_stocks,material_id,stock.date,stock.end_day_stock)
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
    calculate_date_all_material_used_amount()
    #materialのハッシュをまわしていく、このとき単位の変換を行なう。dateとmaterialに対応するstockがすでにあれば更新の配列に、なければ新規の配列にぶちこみ、最後にbulk_insertで終了
    material_ids = @hash.keys
    # stocks_hash = Stock.where(date:previous_day,material_id:material_ids).map{|stock|{stock.material_id => stock}}
    stocks_hash = {}
    Stock.where(date:previous_day,material_id:material_ids).each do|stock|
      stocks_hash[stock.material_id] = stock
    end
    prev_stocks_hash = {}
    Stock.where("date < ?", previous_day).group('material_id').each do |stock|
      prev_stocks_hash[stock.material_id] = stock
    end
    inventory_materials = []
    recent_stocks_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    Stock.where('date > ?', previous_day).order('date asc').each do |stock|
      inventory_materials << stock.material_id if stock.inventory_flag == true
      if recent_stocks_hash[stock.material_id].present?
        recent_stocks_hash[stock.material_id][:stock] << stock
      else
        recent_stocks_hash[stock.material_id][:stock] = [stock]
      end
    end


    @hash.each do |data|
      material_id = data[0]
      used_amount = data[1]
      #すでにstockのobjectがあるかどうか？
      stock = stocks_hash[material_id]
      prev_stock = prev_stocks_hash[material_id]
      if stock
        stock.used_amount = used_amount
        end_day_stock = stock.start_day_stock - used_amount + stock.delivery_amount
        stock.end_day_stock = end_day_stock
        update_stocks << stock
      else
        if prev_stock.present?
          end_day_stock = prev_stock.end_day_stock - used_amount
          new_stocks << Stock.new(material_id:material_id,date:previous_day,used_amount:used_amount,end_day_stock:end_day_stock,start_day_stock:prev_stock.end_day_stock)
        else
          end_day_stock = 0 - used_amount
          new_stocks << Stock.new(material_id:material_id,date:previous_day,used_amount:used_amount,end_day_stock:end_day_stock)
        end
      end
      change_stock(update_stocks,material_id,end_day_stock,inventory_materials,recent_stocks_hash)
    end
    Stock.import new_stocks if new_stocks.present?
    Stock.import update_stocks, on_duplicate_key_update:[:used_amount,:end_day_stock,:start_day_stock] if update_stocks.present?
  end

  def self.initialize_stocks(previous_day)
    # stocks = Stock.where(date:previous_day)
    onday_stock = Stock.where(date:previous_day)
    inventory_materials = []
    recent_stocks_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    Stock.where('date > ?', previous_day).order('date asc').each do |stock|
      inventory_materials << stock.material_id if stock.inventory_flag == true
      if recent_stocks_hash[stock.material_id].present?
        recent_stocks_hash[stock.material_id][:stock] << stock
      else
        recent_stocks_hash[stock.material_id][:stock] = [stock]
      end
    end
    update_stocks = []
    onday_stock.each do |stock|
      stock.used_amount = 0
      end_day_stock = stock.start_day_stock + stock.delivery_amount
      stock.end_day_stock = end_day_stock
      change_stock(update_stocks,stock.material_id,end_day_stock,inventory_materials,recent_stocks_hash)
      update_stocks << stock
    end
    Stock.import update_stocks, on_duplicate_key_update:[:used_amount,:end_day_stock,:start_day_stock] if update_stocks.present?
  end

  def self.date_manufacturing_products(date)
    kurumesi_order_products = KurumesiOrderDetail.joins(:kurumesi_order).where(:kurumesi_orders => {start_time:date,canceled_flag:false}).group('product_id').sum(:number).to_a
    daily_menu_products = DailyMenuDetail.joins(:daily_menu).where(:daily_menus => {start_time:date}).group('product_id').sum(:manufacturing_number).to_a
    @product_manufacturing = kurumesi_order_products + daily_menu_products
  end

  def self.calculate_date_all_material_used_amount
    @product_manufacturing.each do |pm|
      product = Product.find(pm[0])
      menu_materials = MenuMaterial.where(menu_id:product.menus.ids)
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
  def self.change_stock(update_stocks,material_id,end_day_stock,inventory_materials,recent_stocks_hash)
    if inventory_materials.include?(material_id)
      #date以降で棚卸ししてたら、在庫を動かす処理はとくになし
    else
      recent_stocks_hash[material_id][:stock].each_with_index do |dls,i|
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
