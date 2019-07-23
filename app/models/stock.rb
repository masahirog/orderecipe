class Stock < ApplicationRecord
  belongs_to :material
  def self.calculate_stock(date,previous_day)
    @hash = {}
    new_stocks = []
    update_stocks = []

    #dateの対象となるstockのused_amountを一旦0に
    initialize_stocks(previous_day)
    #dateの対象となる、masu_orderとdaily_menuかつ、fixしているものを、product_idと製造数を配列で習得
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
    masu_order_products = MasuOrderDetail.joins(:masu_order).where(:masu_orders => {start_time:date,canceled_flag:false}).group('product_id').sum(:number).to_a
    shogun_order_products = DailyMenuDetail.joins(:daily_menu).where(:daily_menus => {start_time:date,fixed_flag:true}).group('product_id').sum(:manufacturing_number).to_a
    @product_manufacturing = masu_order_products + shogun_order_products
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
end
