class StocksController < ApplicationController
  def index
    today = Date.today
    end_month_date = today.end_of_month
    @dates = []
    i = 0
    while i < 11 do
      @dates << end_month_date - i.months
      i += 1
    end
    @month_total_amount = {}
    @dates.each do |date|
      stocks = Stock.order(date: :desc).includes(:material).where("date <= ?", date).each{|stock|stock.end_day_stock = 0 if stock.end_day_stock < 0}
      stocks = stocks.uniq(&:material_id)
      price = 0
      shokuzai_price = 0
      bento_bihin_price = 0
      kitchen_bihin_price = 0
      stocks.each do |stock|
        material_price = (stock.end_day_stock * stock.material.cost_price)
        price += material_price
        if stock.material.category == '食材（肉・魚）'||stock.material.category == '食材（野菜）'||stock.material.category == '食材（その他）'
          shokuzai_price += material_price
        elsif stock.material.category == '包材・弁当備品'
          bento_bihin_price += material_price
        elsif stock.material.category == 'その他備品・消耗品'
          kitchen_bihin_price += material_price
        end
      end
      @month_total_amount[date] = [price.round,stocks.length,shokuzai_price.round,bento_bihin_price.round,kitchen_bihin_price.round]
    end
  end
  def new
    @stock = Stock.new
    date = params[:date]
    material_id = params[:material_id]
    @stock.date = date
    @stock.material_id = material_id
    prev_stock = Stock.where("date < ?", date).where(material_id:material_id).order("date DESC").first
    if prev_stock.present?
      @stock.start_day_stock = prev_stock.end_day_stock
      @stock.end_day_stock = prev_stock.end_day_stock
    else
      @stock.start_day_stock = 0
      @stock.end_day_stock = 0
    end
    @stock.used_amount = 0
    @stock.delivery_amount = 0
  end
  def edit
    @stock = Stock.find(params[:id])
    @vendors = Vendor.all
  end
  def show
    @stocks = Stock.find(params[:id])
  end
  def material_info
    @material = Material.find(params[:id])
    respond_to do |format|
      format.html
      format.json
    end
  end

  def create
    @storage_locations = StorageLocation.all
    update_stocks = []
    if params[:stock][:end_day_stock_accounting_unit] == ""
      # 空欄だと何もしない
    else
      @stock_hash = {}
      @stock = Stock.new(stock_create_update)
      @material = Material.find(params[:stock][:material_id])
      @stock.end_day_stock = params[:stock][:end_day_stock_accounting_unit].to_f*@material.accounting_unit_quantity
      respond_to do |format|
        if @stock.save
          Stock.change_stock(update_stocks,@material.id,@stock.date,@stock.end_day_stock)
          Stock.import update_stocks, on_duplicate_key_update:[:end_day_stock,:start_day_stock,:inventory_flag] if update_stocks.present?
          if params[:stock][:history_flag] == 'true'
            test_hash
            @history_flag = true
            @class_name = ".inventory_tr_#{@stock.id}"
          else
            check_test(@stock)
          end
          format.js
        else
          render 'new'
        end
      end
    end
  end


  def update
    @storage_locations = StorageLocation.all
    update_stocks = []
    @stock_hash = {}
    @stock = Stock.find(params[:id])
    @material = @stock.material
    end_day_stock_accounting_unit = params[:stock][:end_day_stock_accounting_unit].to_f
    new_end_day_stock = end_day_stock_accounting_unit*@stock.material.accounting_unit_quantity
    new_start_day_stock = new_end_day_stock - @stock.delivery_amount + @stock.used_amount
    inventory_flag = params[:stock][:inventory_flag]
    respond_to do |format|
      if @stock.update(end_day_stock:new_end_day_stock,inventory_flag:inventory_flag,start_day_stock:new_start_day_stock)
        Stock.change_stock(update_stocks,@material.id,@stock.date,new_end_day_stock)
        Stock.import update_stocks, on_duplicate_key_update:[:end_day_stock,:start_day_stock,:inventory_flag] if update_stocks.present?
        if params[:stock][:history_flag] == 'true'
          test_hash
          @history_flag = true
          @class_name = ".inventory_tr_#{@stock.id}"
        else
          check_test(@stock)
        end
        format.js
      else
        format.html { render :new }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end
  end

  def mobile_inventory
    date = Date.parse(params[:date])
    storage_location_id = params[:storage_location_id]
    vendor_id = params[:vendor_id]
    @storage_locations = StorageLocation.all
    if params[:inventory_flag] == 'true'
      inventory_material_ids = Stock.where(date:date,inventory_flag:true).map{|stock|stock.material_id}
      @materials = Material.where(id:inventory_material_ids).order('vendor_id').search(params).where(unused_flag:false).includes(:vendor,:storage_location).page(params[:page]).per(100)
    elsif params[:alert_date].present?
      all_material_ids = Stock.pluck("material_id").uniq
      inventory_ok_material_ids = Stock.where('date >= ?',params[:alert_date]).where(inventory_flag:true).pluck('material_id').uniq
      need_inventory_material_ids = all_material_ids - inventory_ok_material_ids
      @materials = Material.order('vendor_id').search(params).where(id:need_inventory_material_ids).includes(:vendor,:storage_location).page(params[:page]).per(100)
    else
      @materials = Material.order('vendor_id').search(params).where(unused_flag:false).includes(:vendor,:storage_location).page(params[:page]).per(100)
    end
    @stocks_info_hash = {}
    if @materials.present?
      inventory_date_hash = Stock.where(material_id:@materials.ids,inventory_flag:true).order("date ASC").map{|stock|[stock.material_id, stock.date]}.to_h
      stocks = Stock.where('date <= ?',params[:date]).where(material_id:@materials.ids).order("date ASC").map{|stock|[stock.material_id, [stock.end_day_stock,stock.date]]}.to_h
      @materials.each do |material|
        if inventory_date_hash[material.id].present?
          last_inventory_date = inventory_date_hash[material.id].strftime("%-m月%-d日")
        else
          last_inventory_date = ''
        end
        if stocks[material.id].present?
          last_stock = stocks[material.id][0]
          last_stock_date = stocks[material.id][1].strftime("%-m月%-d日")
        else
          last_stock = ''
          last_stock_date = ''
        end
        @stocks_info_hash[material.id] = [last_inventory_date,last_stock,last_stock_date]
      end
      @stocks_hash = Stock.where(date:date,material_id:@materials.ids).map{|stock|[stock.material_id,stock]}.to_h
      @stock_hash ={}
      @hash = {}
      @materials.each do |material|
        aaa(material,date)
      end
    else
      @stocks_hash = []
    end
    render :mobile_inventory, layout: false
  end

  def inventory
    date = Date.parse(params[:date])
    storage_location_id = params[:storage_location_id]
    vendor_id = params[:vendor_id]
    @storage_locations = StorageLocation.all
    if params[:inventory_flag] == 'true'
      inventory_material_ids = Stock.where(date:date,inventory_flag:true).map{|stock|stock.material_id}
      @materials = Material.where(id:inventory_material_ids,stock_management_flag:true).order('vendor_id').search(params).where(unused_flag:false).includes(:vendor,:storage_location).page(params[:page]).per(100)
    elsif params[:alert_date].present?
      all_material_ids = Stock.pluck("material_id").uniq
      inventory_ok_material_ids = Stock.where('date >= ?',params[:alert_date]).where(inventory_flag:true).pluck('material_id').uniq
      need_inventory_material_ids = all_material_ids - inventory_ok_material_ids
      @materials = Material.order('vendor_id').search(params).where(id:need_inventory_material_ids,stock_management_flag:true).includes(:vendor,:storage_location).page(params[:page]).per(100)
    else
      @materials = Material.order('vendor_id').search(params).where(unused_flag:false,stock_management_flag:true).includes(:vendor,:storage_location).page(params[:page]).per(100)
    end
    @stocks_info_hash = {}
    if @materials.present?
      inventory_date_hash = Stock.where(material_id:@materials.ids,inventory_flag:true).order("date ASC").map{|stock|[stock.material_id, stock.date]}.to_h
      stocks = Stock.where('date <= ?',params[:date]).where(material_id:@materials.ids).order("date ASC").map{|stock|[stock.material_id, [stock.end_day_stock,stock.date]]}.to_h
      @materials.each do |material|
        if inventory_date_hash[material.id].present?
          last_inventory_date = inventory_date_hash[material.id].strftime("%-m月%-d日")
        else
          last_inventory_date = ''
        end
        if stocks[material.id].present?
          last_stock = stocks[material.id][0]
          last_stock_date = stocks[material.id][1].strftime("%-m月%-d日")
        else
          last_stock = ''
          last_stock_date = ''
        end
        @stocks_info_hash[material.id] = [last_inventory_date,last_stock,last_stock_date]
      end
      @stocks_hash = Stock.where(date:date,material_id:@materials.ids).map{|stock|[stock.material_id,stock]}.to_h
      @stock_hash ={}
      @hash = {}
      @materials.each do |material|
        aaa(material,date)
      end
    else
      @stocks_hash = []
    end
  end

  def inventory_update
    new_stocks = []
    update_stocks = []
    date = params[:date]
    stocks_once_update_params.each do |stock_param|
      end_day_stock_accounting_unit = stock_param[1][:end_day_stock]
      if end_day_stock_accounting_unit.present?
        material_id = stock_param[0]
        material = Material.find(material_id)
        end_day_stock = end_day_stock_accounting_unit.to_f*material.accounting_unit_quantity
        stock = Stock.find_by(date:date,material_id:material_id)
        if stock
          stock.end_day_stock = end_day_stock
          stock.inventory_flag = true
          update_stocks << stock
        else
          prev_stock = Stock.where("date < ?", date).where(material_id:material_id).order("date DESC").first
          if prev_stock.present?
            new_stocks << Stock.new(material_id:material_id,date:date,end_day_stock:end_day_stock,start_day_stock:prev_stock.end_day_stock,inventory_flag:true)
          else
            new_stocks << Stock.new(material_id:material_id,date:date,end_day_stock:end_day_stock,inventory_flag:true)
          end
        end
        Stock.change_stock(update_stocks,material_id,date,end_day_stock)
      end
    end
    Stock.import new_stocks if new_stocks.present?
    Stock.import update_stocks, on_duplicate_key_update:[:end_day_stock,:start_day_stock,:inventory_flag] if update_stocks.present?

    redirect_to inventory_stocks_path(date:date,page:params[:page],storage_location_id:params[:storage_location_id],vendor_id:params[:vendor_id]),
    notice: "<div class='alert alert-success' role='alert' style='font-size:15px;'>在庫を保存しました！</div>".html_safe
  end

  def inventory_sheet
    date = params[:date]
    storage_location_id = params[:storage_location_id]
    if storage_location_id.present?
      storage_location = StorageLocation.find(storage_location_id)
    else
      storage_location = '全体'
    end
    vendor_id = params[:vendor_id]
    @material_stock = {}
    @materials = Material.order('storage_location_id').order('vendor_id').search(params).where(unused_flag:false).includes(:vendor,:storage_location)
    @materials.each do |material|
      prev_stock = material.stocks.where("date <= ?", date).order("date DESC").first
      if prev_stock
        @material_stock[material.id] = [material,prev_stock.end_day_stock]
      else
        @material_stock[material.id] = [material,'']
      end
    end
    respond_to do |format|
      format.html
      format.pdf do
        pdf = InventorySheetPdf.new(@material_stock,storage_location)
        pdf.font "vendor/assets/fonts/ipaexm.ttf"
        send_data pdf.render,
        filename:    "#{date}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end

  def monthly_inventory
    date = params[:date]
    if params[:category] == '食材'
      category = ['食材（肉・魚）','食材（野菜）','食材（その他）']
    else
      category = params[:category]
    end
    ids = Material.where(category:category).ids
    stocks = Stock.where(material_id:ids).where("date <= ?", date).order(date: :desc).uniq(&:material_id)
    stocks = stocks.each{|stock|stock.end_day_stock = 0 if stock.end_day_stock < 0}
    @stocks_h = stocks.map{|stock| [stock.material_id,[(stock.end_day_stock/stock.material.accounting_unit_quantity),(stock.end_day_stock * stock.material.cost_price),stock.date]]}.to_h
    @stocks_h = Hash[ @stocks_h.sort_by{ |_, v| -v[1] } ]
    material_ids = @stocks_h.keys
    @materials = Material.where(id:material_ids).order("field(id, #{material_ids.join(',')})").page(params[:page]).per(20)
  end

  def history
    @material = Material.find(params[:material_id])
    test_hash
  end

  private
  def stock_create_update
    params.require(:stock).permit(:date,:material_id,:start_day_stock,:end_day_stock,:used_amount,:delivery_amount,:inventory_flag)
  end
  def stocks_once_update_params
    params.require(:stock)
  end

  def test_hash
    today = Date.today
    @stocks_hash = Stock.where(material_id:@material.id).order('date DESC').limit(20).map{|stock|[stock.date, stock]}.to_h
    if @stocks_hash.keys.include?(today)
      @dates = @stocks_hash.keys.sort
    else
      @dates = @stocks_hash.keys.push(today).sort
    end
    @hash_date = {}
    @hash = {}
    menu_ids = MenuMaterial.where(material_id:@material.id).map{|mm|mm.menu_id}.uniq
    product_ids = ProductMenu.where(menu_id:menu_ids).map{|pm|pm.product_id}.uniq
    @dates.each do |date|
      next_date = date + 1
      KurumesiOrderDetail.joins(:kurumesi_order).where(:kurumesi_orders => {start_time:next_date}).where(product_id:product_ids).map do |mod|
        if @hash[mod.product_id].present?
          @hash[mod.product_id] += mod.number.to_i
        else
          @hash[mod.product_id] = mod.number.to_i
        end
      end
      DailyMenuDetail.joins(:daily_menu).where(:daily_menus => {start_time:next_date}).where(product_id:product_ids).map do |dmd|
        if @hash[dmd.product_id].present?
          @hash[dmd.product_id] += dmd.manufacturing_number.to_i
        else
          @hash[dmd.product_id] = dmd.manufacturing_number.to_i
        end
      end
      @hash_date[date] = "<table><thead><tr><th>#{next_date}</th><th>食数</th></tr></thead><tbody>#{@hash.map{|h|"<tr><td>#{Product.find(h[0]).name}</td><td>#{h[1]}食</td><tr>"}.join('')}</tbody></table>"
      @hash = {}
    end
    @unit = @material.accounting_unit
  end

  def check_test(stock)
    @stocks_info_hash = {}
    update_stocks = []
    Stock.change_stock(update_stocks,stock.material_id,stock.date,stock.end_day_stock)
    Stock.import update_stocks, on_duplicate_key_update:[:end_day_stock,:start_day_stock] if update_stocks.present?
    @material = stock.material
    date = stock.date
    aaa(@material,date)
    @class_name = ".inventory_tr_#{@material.id}"
    @stocks_hash = {@material.id => stock}
    @stocks_info_hash[@material.id] = [stock.date,stock.end_day_stock,stock.date]
  end

  def aaa(material,date)
    stocks = Stock.includes(:material).where(material_id:material.id,date:(date - 5)..(date + 10)).order('date ASC')
    @stock_hash[material.id] = stocks.map do |stock|
      if stock.used_amount == 0
        used_amount = "<td style='color:silver;'>0</td>"
      else
        used_amount = "<td style='color:red;'>- #{(stock.used_amount/material.accounting_unit_quantity).ceil(1)}#{material.accounting_unit}</td>"
      end
      if stock.delivery_amount == 0
        delivery_amount = "<td style='color:silver;'>0</td>"
      else
        delivery_amount = "<td style='color:blue;'>+ #{(stock.delivery_amount/material.accounting_unit_quantity).floor(1)}#{material.accounting_unit}</td>"
      end
      if stock.end_day_stock == 0
        end_day_stock = "<td style='color:silver;'>0</td>"
      else
        end_day_stock = "<td style=''>#{(stock.end_day_stock/material.accounting_unit_quantity).floor(1)}#{material.accounting_unit}</td>"
      end
      if stock.inventory_flag == true
        inventory = "<td><span class='label label-success'>棚卸し</span></td>"
      else
        inventory = "<td></td>"
      end
      if stock.date >= date
        ["<tr style='background-color:#ffebcd;'><td>#{stock.date.strftime("%Y/%-m/%-d (#{%w(日 月 火 水 木 金 土)[stock.date.wday]})")}</td>#{delivery_amount}#{used_amount}#{end_day_stock}#{inventory}</tr>"]
      else
        ["<tr><td>#{stock.date.strftime("%Y/%-m/%-d (#{%w(日 月 火 水 木 金 土)[stock.date.wday]})")}</td>#{delivery_amount}#{used_amount}#{end_day_stock}#{inventory}</tr>"]
      end
    end
  end

  def history_test

  end
end
