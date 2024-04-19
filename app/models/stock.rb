require 'csv'
class Stock < ApplicationRecord
  belongs_to :material
  def self.calculate_stock(date,previous_day,store_id)
    @hash = {}
    new_stocks = []
    update_stocks = []

    #dateの対象となるstockのused_amountを一旦0に
    initialize_stocks(previous_day,store_id)
    #全部の弁当と製造数をeachでまわして、materialのuniqと使用量のハッシュ形式にする
    calculate_date_all_material_used_amount(date)
    #materialのハッシュをまわしていく、このとき単位の変換を行なう。dateとmaterialに対応するstockがすでにあれば更新の配列に、なければ新規の配列にぶちこみ、最後にbulk_insertで終了
    material_ids = @hash.keys
    # stocks_hash = Stock.where(date:previous_day,material_id:material_ids).map{|stock|{stock.material_id => stock}}
    stocks_hash = {}

    Stock.where(date:previous_day,material_id:material_ids,store_id:store_id).each do|stock|
      stocks_hash[stock.material_id] = stock
    end
    prev_stocks_hash = {}
    # 半年だけ在庫を遡る
    Stock.where(material_id:material_ids,store_id:store_id).where(date:(previous_day - 180)..previous_day).order('date asc').each do |stock|
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
        if stock.inventory_flag == true
          end_day_stock = stock.end_day_stock
        else
          end_day_stock = stock.start_day_stock - used_amount + stock.delivery_amount
          stock.end_day_stock = end_day_stock
        end
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
      if stock.inventory_flag == true
        end_day_stock = stock.end_day_stock
      else
        end_day_stock = stock.start_day_stock + stock.delivery_amount
        stock.end_day_stock = end_day_stock
      end
      calculate_change_stock(update_stocks,stock.material_id,end_day_stock,inventory_materials,recent_stocks_hash)
      update_stocks << stock
    end
    Stock.import update_stocks, on_duplicate_key_update:[:used_amount,:end_day_stock,:start_day_stock] if update_stocks.present?
  end

  def self.calculate_date_all_material_used_amount(date)
    @product_manufacturing = DailyMenuDetail.joins(:daily_menu).where(:daily_menus => {start_time:date}).group('product_id').sum(:manufacturing_number).to_a
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
      stock = stocks.order('date desc').first
      date = stock.date
      end_day_stock = stock.end_day_stock
      date_later_stocks = Stock.where(material_id:material_id,store_id:store_id).where('date > ?', date).order('date ASC')
      date_later_stocks.each_with_index do |dls,i|
        dls.start_day_stock = end_day_stock
        dls.end_day_stock = dls.start_day_stock - dls.used_amount + dls.delivery_amount
        end_day_stock = dls.end_day_stock
        update_stocks << dls
      end
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

  def self.stock_status_check(store_id)
    msos_arr = []
    today = Date.today
    stocks = Stock.where(store_id:store_id).order("date DESC").where("updated_at BETWEEN ? AND ?", (today-62),today)
    all_material_ids = stocks.pluck("material_id").uniq
    store_material_hash = MaterialStoreOrderable.where(store_id:store_id,material_id:all_material_ids).map{|mso|[mso.material_id,mso]}.to_h
    materials = Material.where(id:all_material_ids)
    materials.each do |material|
      mso = store_material_hash[material.id]
      if mso.present?
        latest_stock = stocks.find_by(material_id:material.id)
        last_inventory = stocks.find_by(material_id:material.id,inventory_flag:true)
        if last_inventory.present?
          mso.last_inventory_date = last_inventory.date
          msos_arr << mso
        end
      end
    end
    MaterialStoreOrderable.import msos_arr, on_duplicate_key_update: [:last_inventory_date]
  end


  # def self.inventory_past_stock_update
  #   # 1日遡る計算の場合（キッチンで翌月1日に棚卸しをした場合）
  #   new_stocks = []
  #   update_stocks = []
  #   material_ids = [1,11,41,51,61,91,101,121,141,241,291,331,351,361,421,451,481,491,541,631,661,681,691,721,871,901,1091,1271,2011,
  #     2041,2121,2141,2261,2281,2441,3201,3821,3891,3901,3911,3921,3941,4001,4021,4031,4091,4451,4501,4571,4631,4721,4731,5831,6671,
  #     7031,7361,8111,8721,8731,8761,8811,9001,9071,9141,9261,10041,10071,10091,10101,10141,10231,10241,10321,10331,10361,10481,10491,
  #     10601,10841,10901,11081,11091,11471,11531,11571,11581,11631,11641,12102,12211,12221,12291,12301,12331,12411,12651,12701,12771,
  #     12831,12891,13081,13151,13251,13411,13611,14021,15041,15291,15301,15341,15451,15811,16161,16231,16281,16311,16421,16481,16501,
  #     16661,16821,17131,17911,18161,18171,18311,18341,18381,18401,18471,18481,18591,18861,19281,19691,19921,20111,20701,20711,20721,
  #     20751,20781,20981,21031,21051,21381,21691,22171,22571,23101,23221,23381,23831,23891,23901,24581,25251,25261,25281,25341,25381,
  #     25501,25541,25551,25571,25741,26051,26081,26091,26101,26161,26181,26271,26359,26479,26789,27049,27139,27169,27219,27299,27319,
  #     27559,27619,27829,27859,27869,27969,28009,28039,28059,28079,28169,28199,28209,28219,28249,28259,28299,28309,28339,28389,28459,
  #     28469,28539,28589,28639,28649,28659,28759,29009,29119,29289,29769,29789,29969,29979,29999,30009,30169,30259,30309,30339,30389,
  #     30399,30429,30439,30449,30489,30499,30609,30619,30639,30849,31119,31219,31229,31239,31259,31329,31409,31459,31539,31569,31589,
  #     31599,31609,31699,31709,31719,31729,31739,31749,31759,31769,31779,31819,31839,31879,32149,32229,32279,32289,32299,32384,32434,
  #     32444,32454,32524,32644,32654,32674,32684,32714,32924,33204,33214,33344,33354,33364,33444,33464]
  #   material_ids.each do |material_id|
  #     date = Date.new(2023,7,1)
  #     yesterday = date - 1
  #     stock = Stock.find_by(date:date,material_id:material_id,store_id:39)
  #     start_day_stock = stock.start_day_stock
  #     yesterday_stock = Stock.find_by(date:yesterday,material_id:material_id,store_id:39)      
  #     if yesterday_stock.present?
  #       yesterday_stock.end_day_stock = start_day_stock
  #       yesterday_stock.inventory_flag = true
  #       update_stocks << yesterday_stock
  #     else
  #       yesterday_stock = Stock.new(material_id:material_id,date:yesterday,start_day_stock:start_day_stock,end_day_stock:start_day_stock,
  #         used_amount:0,delivery_amount:0,inventory_flag:true,created_at:Time.now,updated_at:Time.now,store_id:39)
  #       new_stocks << yesterday_stock
  #     end
  #   end
  #   Stock.import new_stocks if new_stocks.present?
  #   Stock.import update_stocks, on_duplicate_key_update:[:end_day_stock,:start_day_stock,:inventory_flag] if update_stocks.present?
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

end
