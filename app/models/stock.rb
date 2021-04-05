class Stock < ApplicationRecord
  belongs_to :material

  # 棚卸しをcsv等で一括アップデートしたときに、それ以降の在庫を動かす処理
  def self.csv_stocks_update
    update_stocks = []

    # stock_ids = [
    #   913799,913839,913909,914059,914079,914089,914129,914149,914169,914239,914249,914309,914319,914339,914429,914469,914509,914699,914719,914729,
    #   914749,914889,914919,914929,915269,918459,918469,918479,919519,919529,919889,919969,919989,920199,922999,923009,902879,902889,903039,903129,
    #   903279,903299,908009,915579,915589,915689,915849,918489,919629,922109,922269,924329,924339,925519,925709,925809,925899,926109,881149,881159,
    #   881219,881249,881349,881359,881449,887499,887539,887559,887619,887639,887649,887739,887749,887769,887779,887789,887859,887899,887909,908889,
    #   908899,908939,908989,917199,917289,917369,917409,917449,917459,917479,917489,919569,923819,923849,923869,925119,925179,925199,925219,925229,
    #   925239,925309,925319,925429,926249,926259,926329,926369,926449,926529,926539,926569,926649,926789,926809,926819,926839,930489,930499,930509,
    #   930769,932709,932719,933589,933599,933609,933619,933629,933639,933649,933659,933669,933679,933689,933699,926899,926949,926969,927419,927539,
    #   927629,927639,927649,927759,927799,927989,928069,928109,932169,932179,932199,932209,932219,932229
    # ]
    # stock_ids.each do |stock_id|
    #   stock = Stock.find(stock_id)
    #   change_stock(update_stocks,stock.material_id,stock.date,stock.end_day_stock)
    # end

    material_ids = [
      [19691,"2021/03/29"],[16511,"2021/03/29"],[5271,"2021/03/29"],[7361,"2021/03/29"],[4631,"2021/03/29"],[8731,"2021/03/29"],[19651,"2021/03/29"],[18341,"2021/03/29"],[19661,"2021/03/29"],[6891,"2021/03/29"],
      [15971,"2021/03/29"],[26569,"2021/03/29"],[22611,"2021/03/29"],[4381,"2021/03/29"],[4271,"2021/03/29"],[23221,"2021/03/29"],[18171,"2021/03/29"],[6861,"2021/03/29"],[23411,"2021/03/29"],[26399,"2021/03/29"],
      [26409,"2021/03/29"],[26869,"2021/03/29"],[15451,"2021/03/29"],[25231,"2021/03/29"],[20711,"2021/03/29"],[16401,"2021/03/29"],[19471,"2021/03/29"],[12601,"2021/03/29"],[20981,"2021/03/29"],[16101,"2021/03/29"],
      [20931,"2021/03/29"],[22191,"2021/03/29"],[20961,"2021/03/29"],[1341,"2021/03/29"],[22951,"2021/03/29"],[26161,"2021/03/29"],[24341,"2021/03/29"],[24181,"2021/03/29"],[15711,"2021/03/29"],[15701,"2021/03/29"],
      [25501,"2021/03/29"],[25221,"2021/03/29"],[7521,"2021/03/29"],[25261,"2021/03/29"],[24351,"2021/03/29"],[11261,"2021/03/29"],[26001,"2021/03/29"],[25151,"2021/03/29"],[21031,"2021/03/29"],[19491,"2021/03/29"],
      [12891,"2021/03/29"],[25931,"2021/03/29"],[25421,"2021/03/29"],[26499,"2021/03/29"],[25941,"2021/03/29"],[25741,"2021/03/29"],[25141,"2021/03/29"],[20721,"2021/03/29"],[15811,"2021/03/29"],[24141,"2021/03/29"],
      [25961,"2021/03/29"],[26509,"2021/03/29"],[13251,"2021/03/29"],[22521,"2021/03/29"],[3891,"2021/03/29"],[25721,"2021/03/29"],[13401,"2021/03/29"],[23441,"2021/03/29"],[2261,"2021/03/29"],[9031,"2021/03/29"],
      [18861,"2021/03/29"],[18161,"2021/03/29"],[2121,"2021/03/29"],[17941,"2021/03/29"],[23691,"2021/03/29"],[18651,"2021/03/29"],[16281,"2021/03/29"],[16311,"2021/03/29"],[25731,"2021/03/29"],[10301,"2021/03/29"],
      [14891,"2021/03/29"],[10361,"2021/03/29"],[16331,"2021/03/29"],[26281,"2021/03/29"],[14881,"2021/03/29"],[20001,"2021/03/29"],[10071,"2021/03/29"],[13591,"2021/03/29"],[2781,"2021/03/29"],[26301,"2021/03/29"],
      [24421,"2021/03/29"],[15261,"2021/03/29"],[25551,"2021/03/29"],[21191,"2021/03/29"],[9261,"2021/03/29"],[20781,"2021/03/29"],[4451,"2021/03/29"],[26131,"2021/03/29"],[26141,"2021/03/29"],[4761,"2021/03/29"],
      [22751,"2021/03/29"],[26291,"2021/03/29"],[10241,"2021/03/29"],[15341,"2021/03/29"],[10951,"2021/03/29"],[631,"2021/03/29"],[21621,"2021/03/29"],[25381,"2021/03/29"],[14931,"2021/03/29"],[15891,"2021/03/29"],
      [2581,"2021/03/29"],[8721,"2021/03/29"],[17301,"2021/03/29"],[17591,"2021/03/29"],[18291,"2021/03/29"],[15291,"2021/03/29"],[2761,"2021/03/29"],[18441,"2021/03/29"],[19251,"2021/03/29"],[21551,"2021/03/29"],
      [23921,"2021/03/29"],[15081,"2021/03/29"],[26151,"2021/03/29"],[2611,"2021/03/29"],[15301,"2021/03/29"],[18961,"2021/03/29"],[15281,"2021/03/29"],[14981,"2021/03/29"],[14821,"2021/03/29"],[2771,"2021/03/29"],
      [25401,"2021/03/29"],[11851,"2021/03/29"],[5221,"2021/03/29"],[21151,"2021/03/29"],[18331,"2021/03/29"],[12501,"2021/03/29"],[19421,"2021/03/29"],[20021,"2021/03/29"],[25951,"2021/03/29"],[23951,"2021/03/29"],
      [17891,"2021/03/29"],[17901,"2021/03/29"],[12331,"2021/03/29"],[23831,"2021/03/29"],[19751,"2021/03/29"],[26649,"2021/03/29"],[26389,"2021/03/29"],[21891,"2021/03/29"],[26181,"2021/03/29"],[16441,"2021/03/29"],
      [24451,"2021/03/29"],[25341,"2021/03/29"],[19631,"2021/03/29"],[23901,"2021/03/29"],[11081,"2021/03/29"],[24411,"2021/03/29"],[26449,"2021/03/29"],[17861,"2021/03/29"],[2011,"2021/03/29"],[3271,"2021/03/29"],
      [3201,"2021/03/29"],[23891,"2021/03/29"],[26191,"2021/03/29"],[25441,"2021/03/29"],[8761,"2021/03/29"],[19051,"2021/03/29"],[23621,"2021/03/29"],[14021,"2021/03/29"],[7991,"2021/03/29"],[15011,"2021/03/29"],
      [11331,"2021/03/29"],[19561,"2021/03/29"],[8811,"2021/03/29"],[12711,"2021/03/29"],[2991,"2021/03/29"],[2981,"2021/03/29"],[14961,"2021/03/29"],[25871,"2021/03/29"],[15041,"2021/03/29"],[26231,"2021/03/29"],
      [1311,"2021/03/29"],[14181,"2021/03/29"],[19601,"2021/03/29"],[8061,"2021/03/29"],[20771,"2021/03/29"],[3041,"2021/03/29"],[17001,"2021/03/29"],[17621,"2021/03/29"],[5951,"2021/03/29"],[8651,"2021/03/29"],
      [21691,"2021/03/29"],[11581,"2021/03/29"],[4871,"2021/03/29"],[18571,"2021/03/29"],[4311,"2021/03/29"],[5061,"2021/03/29"],[18481,"2021/03/29"],[20561,"2021/03/29"],[861,"2021/03/29"],[10601,"2021/03/29"],
      [25571,"2021/03/29"],[26041,"2021/03/29"],[15171,"2021/03/29"],[25811,"2021/03/29"],[5091,"2021/03/29"],[4921,"2021/03/29"],[871,"2021/03/29"],[14801,"2021/03/29"],[1081,"2021/03/29"],[4911,"2021/03/29"],
      [8681,"2021/03/29"],[11931,"2021/03/29"],[2111,"2021/03/29"],[22171,"2021/03/29"],[91,"2021/03/29"],[51,"2021/03/29"],[18401,"2021/03/29"],[12741,"2021/03/29"],[13611,"2021/03/29"],[541,"2021/03/29"],
      [16821,"2021/03/29"],[15871,"2021/03/29"],[4721,"2021/03/29"],[22201,"2021/03/29"],[3971,"2021/03/29"],[3831,"2021/03/29"],[4031,"2021/03/29"],[25561,"2021/03/29"],[26739,"2021/03/29"],[901,"2021/03/29"],
      [26789,"2021/03/29"],[18061,"2021/03/29"],[11251,"2021/03/29"],[25371,"2021/03/29"],[18311,"2021/03/29"],[17131,"2021/03/29"],[18131,"2021/03/29"],[3991,"2021/03/29"],[3911,"2021/03/29"],[26271,"2021/03/29"],
      [10781,"2021/03/29"],[4521,"2021/03/29"],[21381,"2021/03/29"],[21051,"2021/03/29"],[6911,"2021/03/29"],[141,"2021/03/29"],[26639,"2021/03/29"],[491,"2021/03/29"],[661,"2021/03/29"],[22571,"2021/03/29"],
      [2101,"2021/03/29"],[11531,"2021/03/29"],[15371,"2021/03/29"],[1901,"2021/03/29"],[25641,"2021/03/29"],[16421,"2021/03/29"],[10101,"2021/03/29"],[4501,"2021/03/29"],[9141,"2021/03/29"],[10321,"2021/03/29"],
      [12411,"2021/03/29"],[10141,"2021/03/29"],[17181,"2021/03/29"],[8321,"2021/03/29"],[11091,"2021/03/29"],[12102,"2021/03/29"],[10331,"2021/03/29"],[13151,"2021/03/29"],[13111,"2021/03/29"],[41,"2021/03/29"],
      [12651,"2021/03/29"],[17091,"2021/03/29"],[1091,"2021/03/29"],[26359,"2021/03/29"],[4731,"2021/03/29"],[24091,"2021/03/29"],[12941,"2021/03/29"],[17611,"2021/03/29"],[26889,"2021/03/29"],[331,"2021/03/29"],
      [61,"2021/03/29"],[7891,"2021/03/29"],[12301,"2021/03/29"],[481,"2021/03/29"],[2041,"2021/03/29"],[17851,"2021/03/29"],[26429,"2021/03/29"],[7931,"2021/03/29"],[7031,"2021/03/29"],[11,"2021/03/29"],[19921,"2021/03/29"],
      [241,"2021/03/29"],[25321,"2021/03/29"],[10041,"2021/03/29"],[18471,"2021/03/29"],[101,"2021/03/29"],[21291,"2021/03/29"],[11631,"2021/03/29"],[421,"2021/03/29"],[26859,"2021/03/29"],[26091,"2021/03/29"],
      [10841,"2021/03/29"],[26319,"2021/03/29"],[17191,"2021/03/29"],[25541,"2021/03/29"],[11651,"2021/03/29"],[11421,"2021/03/29"],[18301,"2021/03/29"],[811,"2021/03/29"],[10521,"2021/03/29"],[2221,"2021/03/29"],
      [451,"2021/03/29"],[25581,"2021/03/29"],[3901,"2021/03/29"],[4091,"2021/03/29"],[3951,"2021/03/29"],[4001,"2021/03/29"],[10091,"2021/03/29"],[9081,"2021/03/29"],[4741,"2021/03/29"],[10431,"2021/03/29"],
      [12221,"2021/03/29"],[13081,"2021/03/29"],[26101,"2021/03/29"],[26899,"2021/03/29"],[17151,"2021/03/29"],[25251,"2021/03/29"],[3821,"2021/03/29"],[16661,"2021/03/29"],[10891,"2021/03/29"],[9001,"2021/03/29"],
      [361,"2021/03/29"],[2531,"2021/03/29"],[13411,"2021/03/29"],[17911,"2021/03/29"],[351,"2021/03/29"],[11471,"2021/03/29"],[10011,"2021/03/29"],[25351,"2021/03/29"],[381,"2021/03/29"],[4021,"2021/03/29"],
      [10561,"2021/03/29"],[18211,"2021/03/29"],[391,"2021/03/29"],[11571,"2021/03/29"],[11321,"2021/03/29"],[11621,"2021/03/29"],[23001,"2021/03/29"],[461,"2021/03/29"],[9071,"2021/03/29"],[10481,"2021/03/29"],
      [11311,"2021/03/29"],[21,"2021/03/29"],[16231,"2021/03/29"],[26599,"2021/03/29"],[26799,"2021/03/29"],[20321,"2021/03/29"],[16251,"2021/03/29"],[16261,"2021/03/29"],[16271,"2021/03/29"],[18431,"2021/03/29"],
      [4931,"2021/03/29"],[15311,"2021/03/29"],[7561,"2021/03/29"],[17541,"2021/03/29"],[26879,"2021/03/29"],[16061,"2021/03/29"],[11911,"2021/03/29"],[16081,"2021/03/29"],[7241,"2021/03/29"],[23791,"2021/03/29"],
      [121,"2021/03/29"],[13661,"2021/03/29"],[20751,"2021/03/29"],[2441,"2021/03/29"],[26081,"2021/03/29"],[12831,"2021/03/29"],[821,"2021/03/29"],[23551,"2021/03/29"],[25311,"2021/03/29"],[23931,"2021/03/29"],
      [24391,"2021/03/29"],[15941,"2021/03/29"],[15781,"2021/03/29"],[4571,"2021/03/29"],[3921,"2021/03/29"],[3941,"2021/03/29"],[20291,"2021/03/29"],[4011,"2021/03/29"]
    ]

    material_ids.each do |material_id_and_date|
      material_id = material_id_and_date[0]
      date = material_id_and_date[1]
      stock = Stock.find_by(date:date,material_id:material_id)
      change_stock(update_stocks,material_id,stock.date,stock.end_day_stock)
    end
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
    calculate_date_all_material_used_amount()
    #materialのハッシュをまわしていく、このとき単位の変換を行なう。dateとmaterialに対応するstockがすでにあれば更新の配列に、なければ新規の配列にぶちこみ、最後にbulk_insertで終了
    material_ids = @hash.keys
    # stocks_hash = Stock.where(date:previous_day,material_id:material_ids).map{|stock|{stock.material_id => stock}}
    stocks_hash = {}

    Stock.where(date:previous_day,material_id:material_ids).each do|stock|
      stocks_hash[stock.material_id] = stock
    end
    prev_stocks_hash = {}
    stocks = Stock.where("date < ?", previous_day).order('date desc')
    Stock.group('material_id').from(stocks, :stocks).each do |stock|
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
      calculate_change_stock(update_stocks,material_id,end_day_stock,inventory_materials,recent_stocks_hash)
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
      calculate_change_stock(update_stocks,stock.material_id,end_day_stock,inventory_materials,recent_stocks_hash)
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
  def self.calculate_change_stock(update_stocks,material_id,end_day_stock,inventory_materials,recent_stocks_hash)
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

  def self.change_stock(update_stocks,material_id,date,end_day_stock)
    stocks = Stock.where(material_id:material_id).where('date > ?', date).where(inventory_flag:true)
    if stocks.present?
    else
      date_later_stocks = Stock.where(material_id:material_id).where('date > ?', date).order('date ASC')
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
