require 'csv'
class Stock < ApplicationRecord
  belongs_to :material
  # def self.past_5days_stock_update
  #   update_stocks = []
  #   material_ids = [27519,26389,26739,26449,26469,27279,27019,27179,23691,20021,19421,25871,19561,19751,21891,25401,21151,24581,22751,19631,19601,21191,19841,24181,5951,6251,10451,16511,
  #   15261,14981,3271,17861,3201,2761,2581,10301,17611,26191,10951,8811,15891,2611,13091,19051,2991,15041,14021,9031,2781,18331,2981,14181,14931,3041,1,25971,15321,19221,
  #   27559,23001,19111,27569,27299,19031,27549,14881,23411,14891,18161,26051,19291,17911,24281,24311,24301,17301,24341,24351,25721,23221,25731,19691,26399,27529,26409,25141,
  #   26509,26499,27679,27689,26281,26131,27029,25151,16281,18441,26569,26869,26141,25961,22611,21551,15681,27109,25931,15691,26291,25941,25231,19251,26301,27619,27059,25221,
  #   16311,25421,25381,25211,25951,18341,15711,17891,15701,17901,23331,23321,24551,26121,26111,27479,27509,27469,26031,19651,19661,18171,8061,23621,19471,7521,20711,8681,19491,
  #   7991,21031,23901,7891,11081,24091,25501,7531,25551,7931,21691,18381,21381,20721,23891,8321,10241,8651,27319,20701,26101,21051,25571,8661,25741,15301,15291,5271,
  #   17921,15451,16081,7361,6891,11851,15011,11931,6911,18861,6671,16981,7031,6861,8751,17181,25541,16241,26271,19921,13251,12331,14961,351,15811,101,18291,11051,16821,16101,
  #   121,541,18311,10361,1271,8721,2041,23791,14821,25641,22171,17851,26789,15081,11581,23441,18481,15971,10011,14801,451,15871,13661,331,1311,91,901,17591,25351,20561,27089,
  #   41,20771,11571,18471,18131,17151,15341,12301,12411,27189,361,27139,10781,141,871,25811,51,27099,20781,15171,25981,15281,61,10071,12741,2111,22571,16401,26639,16481,
  #   1081,13611,491,16231,291,23921,11331,241,20981,8731,1091,25321,461,2011,12891,1901,26889,25261,20751,18651,21291,13151,11631,11251,421,11311,26181,26231,17191,661,
  #   481,16331,12221,25471,11091,24451,26359,8761,861,27169,11261,10041,12651,26859,26091,631,11321,17941,18061,10521,391,16161,17131,2121,25251,16661,27579,25561,11561,
  #   9261,25341,22951,9071,11651,18401,10841,851,11471,11,381,11531,12211,26319,26081,17091,23831,24411,2261,20931,24421,151,2101,17831,26649,4201,12501,3951,26151,3991,3921,
  #   3901,10601,3941,4631,13591,4571,4721,16421,3831,22191,4731,4091,26001,4021,10141,10331,4381,20001,21621,9001,26161,13401,10101,3821,3891,12711,12102,13081,4271,3911,10931,
  #   4031,9141,4001,10321,10091,3971,4521,10481,4311,20291,13411,4761,12941,9081,4501,4451,10561,10901]
  #   material_ids.each do |material_id|
  #     date = Date.new(2021,8,5)
  #     stock = Stock.find_by(date:date,material_id:material_id)
  #     start_day_stock = stock.end_day_stock - stock.delivery_amount + stock.used_amount
  #     stock.start_day_stock = start_day_stock
  #     update_stocks << stock
  #     date_before_stocks = Stock.where(material_id:material_id).where('date >= ?', '2021-07-31').where('date < ?', date).order('date DESC')
  #     date_before_stocks.each_with_index do |dls,i|
  #       dls.end_day_stock = start_day_stock
  #       start_day_stock = start_day_stock - dls.delivery_amount + dls.used_amount
  #       dls.start_day_stock = start_day_stock
  #       update_stocks << dls
  #     end
  #   end
  #   Stock.import update_stocks, on_duplicate_key_update:[:end_day_stock,:start_day_stock] if update_stocks.present?
  # end


  # def self.upload_data(file)
  #   new_stocks = []
  #   update_stocks = []
  #   material_ids = []
  #   materials_hash = {}
  #   material_id_date_arr = []
  #   CSV.foreach(file.path, headers: true) do |row|
  #     row = row.to_hash
  #     material_ids << row['material_id']
  #   end
  #   materials_hash = Material.where(id:material_ids).map{|material|[material.id,material.accounting_unit_quantity]}.to_h
  #   CSV.foreach(file.path, headers: true) do |row|
  #     row = row.to_hash
  #     material_id = row["material_id"].to_i
  #     date = row['date']
  #     inventory_flag = row['inventory_flag']
  #     csv_end_day_stock = row["end_day_stock"].to_f
  #     end_day_stock = (csv_end_day_stock * materials_hash[material_id]).round(1)
  #     material_id_date_arr << [material_id,date]
  #     stock = Stock.find_by(material_id:material_id,date:date)
  #     if stock.present?
  #       stock.end_day_stock = end_day_stock
  #       stock.inventory_flag = inventory_flag
  #       update_stocks << stock
  #     else
  #       stock = Stock.new(material_id:material_id,date:date,inventory_flag:inventory_flag,
  #         start_day_stock:end_day_stock,end_day_stock:end_day_stock,used_amount:0,delivery_amount:0)
  #       new_stocks << stock
  #     end
  #   end
  #   created_stocks = Stock.import new_stocks
  #   updated_stocks = Stock.import update_stocks, on_duplicate_key_update:[:inventory_flag,:end_day_stock]
  #   csv_stocks_update(material_id_date_arr)
  #   return (new_stocks.count+update_stocks.count)
  # end




  # 棚卸しをcsv等で一括アップデートしたときに、それ以降の在庫を動かす処理
  # def self.csv_stocks_update(material_id_date_arr)
  #   update_stocks = []
  #   # stock_ids = [927629,927639,927649,927759,927799,927989,928069,928109,932169,932179,932199,932209,932219,932229]
  #   # stock_ids.each do |stock_id|
  #   #   stock = Stock.find(stock_id)
  #   #   change_stock(update_stocks,stock.material_id,stock.date,stock.end_day_stock)
  #   # end
  #
  #   # material_ids = [[19691,"2021/03/29"],[16511,"2021/03/29"],[5271,"2021/03/29"],[7361,"2021/03/29"],[4631,"2021/03/29"],[8731,"2021/03/29"],[19651,"2021/03/29"],[18341,"2021/03/29"],[19661,"2021/03/29"],[6891,"2021/03/29"]]
  #
  #   material_id_date_arr.each do |material_id_and_date|
  #     material_id = material_id_and_date[0]
  #     date = material_id_and_date[1]
  #     stock = Stock.find_by(date:date,material_id:material_id)
  #     change_stock(update_stocks,material_id,stock.date,stock.end_day_stock)
  #   end
  #   Stock.import update_stocks, on_duplicate_key_update:[:end_day_stock,:start_day_stock,:inventory_flag] if update_stocks.present?
  # end


  def self.calculate_stock(date,previous_day,store_id)
    @hash = {}
    new_stocks = []
    update_stocks = []

    #dateの対象となるstockのused_amountを一旦0に
    initialize_stocks(previous_day,store_id)
    #dateの対象となる、kurumesi_orderとdaily_menuかつ、fixしているものを、product_idと製造数を配列で習得
    date_manufacturing_products(date)
    #全部の弁当と製造数をeachでまわして、materialのuniqと使用量のハッシュ形式にする
    calculate_date_all_material_used_amount()
    #materialのハッシュをまわしていく、このとき単位の変換を行なう。dateとmaterialに対応するstockがすでにあれば更新の配列に、なければ新規の配列にぶちこみ、最後にbulk_insertで終了
    material_ids = @hash.keys
    # stocks_hash = Stock.where(date:previous_day,material_id:material_ids).map{|stock|{stock.material_id => stock}}
    stocks_hash = {}

    Stock.where(date:previous_day,material_id:material_ids,store_id:store_id).each do|stock|
      stocks_hash[stock.material_id] = stock
    end
    prev_stocks_hash = {}
    Stock.where(material_id:material_ids,store_id:store_id).where("date < ?", previous_day).order('date asc').each do |stock|
      prev_stocks_hash[stock.material_id] = stock
    end
    inventory_materials = []
    recent_stocks_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    Stock.where(store_id:store_id).where('date > ?', previous_day).order('date asc').each do |stock|
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
          new_stocks << Stock.new(material_id:material_id,date:previous_day,used_amount:used_amount,end_day_stock:end_day_stock,start_day_stock:prev_stock.end_day_stock,store_id:store_id)
        else
          end_day_stock = 0 - used_amount
          new_stocks << Stock.new(material_id:material_id,date:previous_day,used_amount:used_amount,end_day_stock:end_day_stock,store_id:store_id)
        end
      end
      calculate_change_stock(update_stocks,material_id,end_day_stock,inventory_materials,recent_stocks_hash)
    end
    Stock.import new_stocks if new_stocks.present?
    Stock.import update_stocks, on_duplicate_key_update:[:used_amount,:end_day_stock,:start_day_stock] if update_stocks.present?
  end

  def self.initialize_stocks(previous_day,store_id)
    # stocks = Stock.where(date:previous_day)
    onday_stock = Stock.where(date:previous_day,store_id:store_id)
    inventory_materials = []
    recent_stocks_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    Stock.where('date > ?', previous_day).where(store_id:store_id).order('date asc').each do |stock|
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

  def self.change_stock(update_stocks,material_id,date,end_day_stock,store_id)
    stocks = Stock.where(material_id:material_id,store_id:store_id).where('date > ?', date).where(inventory_flag:true)
    if stocks.present?
    else
      date_later_stocks = Stock.where(material_id:material_id,store_id:store_id).where('date > ?', date).order('date ASC')
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
    stocks = Stock.where(store_id:store_id).order("date DESC").where('date <= ?',today)
    all_material_ids = stocks.pluck("material_id").uniq
    materials = Material.where(id:all_material_ids)
    materials.each do |material|
      latest_stock = stocks.find_by(material_id:material.id)
      last_inventory = stocks.find_by(material_id:material.id,inventory_flag:true)
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
      materials_arr << material
    end
    Material.import materials_arr, on_duplicate_key_update: [:last_inventory_date,:need_inventory_flag]
  end
end
