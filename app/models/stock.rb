require 'csv'
class Stock < ApplicationRecord
  belongs_to :material

  def self.upload_data(file)
    new_stocks = []
    update_stocks = []
    material_ids = []
    materials_hash = {}
    material_id_date_arr = []
    CSV.foreach(file.path, headers: true) do |row|
      row = row.to_hash
      material_ids << row['material_id']
    end
    materials_hash = Material.where(id:material_ids).map{|material|[material.id,material.accounting_unit_quantity]}.to_h
    CSV.foreach(file.path, headers: true) do |row|
      row = row.to_hash
      material_id = row["material_id"].to_i
      date = row['date']
      csv_end_day_stock = row["end_day_stock"].to_f
      end_day_stock = (csv_end_day_stock * materials_hash[material_id]).round(1)
      material_id_date_arr << [material_id,date]
      stock = Stock.find_by(material_id:material_id,date:date)
      if stock.present?
        stock.end_day_stock = end_day_stock
        stock.inventory_flag = true
        update_stocks << stock
      else
        stock = Stock.new(material_id:material_id,date:date,inventory_flag:true,
          start_day_stock:end_day_stock,end_day_stock:end_day_stock,used_amount:0,delivery_amount:0)
        new_stocks << stock
      end
    end
    created_stocks = Stock.import new_stocks
    updated_stocks = Stock.import update_stocks, on_duplicate_key_update:[:inventory_flag,:end_day_stock]
    csv_stocks_update(material_id_date_arr)
    return (new_stocks.count+update_stocks.count)
  end




  # 棚卸しをcsv等で一括アップデートしたときに、それ以降の在庫を動かす処理
  def self.csv_stocks_update(material_id_date_arr)
    update_stocks = []
    # stock_ids = [927629,927639,927649,927759,927799,927989,928069,928109,932169,932179,932199,932209,932219,932229]
    # stock_ids.each do |stock_id|
    #   stock = Stock.find(stock_id)
    #   change_stock(update_stocks,stock.material_id,stock.date,stock.end_day_stock)
    # end

    # material_ids = [[19691,"2021/03/29"],[16511,"2021/03/29"],[5271,"2021/03/29"],[7361,"2021/03/29"],[4631,"2021/03/29"],[8731,"2021/03/29"],[19651,"2021/03/29"],[18341,"2021/03/29"],[19661,"2021/03/29"],[6891,"2021/03/29"]]

    material_id_date_arr.each do |material_id_and_date|
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
