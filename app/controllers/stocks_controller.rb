class StocksController < ApplicationController
  def index
    arr = []
    date = params[:date]
    stocks = Stock.where(date:date).map{|stock|[stock.material_id,[stock.used_amount,stock.delivery_amount,stock.start_day_stock,stock.end_day_stock]]}.to_h
    storage_location_id = params[:storage_location_id]
    @storage_locations = StorageLocation.all
    if params[:inventory_flag] == 'true'
      inventory_material_ids = Stock.where(date:date,inventory_flag:true).map{|stock|stock.material_id}
      @materials = Material.where(id:inventory_material_ids).order('vendor_id').search(params).where(unused_flag:false).includes(:vendor,:storage_location).page(params[:page]).per(100)
    else
      @materials = Material.order('vendor_id').search(params).where(unused_flag:false).includes(:vendor,:storage_location).page(params[:page]).per(30)
    end
    @materials.each do |material|
      if stocks[material.id].present?
        used_amount = "- #{(stocks[material.id][0]).round(1)} #{material.order_unit}"
        delivery_amount = "+ #{(stocks[material.id][1]).round(1)} #{material.order_unit}"
        start_day_stock = "#{(stocks[material.id][2]).round(1)} #{material.order_unit}"
        end_day_stock = "#{(stocks[material.id][3]).round(1)} #{material.order_unit}"
      else
        used_amount = ""
        delivery_amount = ""
        start_day_stock = ""
        end_day_stock = ""
      end
      arr << [material.id,material.storage_location.name,material.name,material.vendor.company_name,used_amount,delivery_amount,start_day_stock,end_day_stock]
    end
    @materials_inventory = arr
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
    @stock = Stock.new(stock_create_update)
     if @stock.save
       redirect_to history_stocks_path(material_id:@stock.material_id)
     else
       render 'new'
     end
  end


  def update
    @stock = Stock.find(params[:id])
    respond_to do |format|
      if @stock.update(stock_create_update)
        if @stock.inventory_flag == true
          update_stocks = []
          Stock.change_stock(update_stocks,@stock.material_id,@stock.date,@stock.end_day_stock)
          Stock.import update_stocks, on_duplicate_key_update:[:end_day_stock,:start_day_stock] if update_stocks.present?
        end
        format.html { redirect_to history_stocks_path(material_id:@stock.material_id), notice: '更新OK' }
        format.json { render :show, status: :ok, location: @stock }
      else
        format.html { render :edit }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end
  end

  def inventory
    date = params[:date]
    storage_location_id = params[:storage_location_id]
    vendor_id = params[:vendor_id]
    @storage_locations = StorageLocation.all
    if params[:inventory_flag] == 'true'
      inventory_material_ids = Stock.where(date:date,inventory_flag:true).map{|stock|stock.material_id}
      @materials = Material.where(id:inventory_material_ids).order('vendor_id').search(params).where(unused_flag:false).includes(:vendor,:storage_location).page(params[:page]).per(100)
    else
      @materials = Material.order('vendor_id').search(params).where(unused_flag:false).includes(:vendor,:storage_location).page(params[:page]).per(30)
    end
    if @materials.present?
      @stocks_hash = Stock.where(date:date,material_id:@materials.ids).map{|stock|[stock.material_id,stock]}.to_h
    else
      @stocks_hash = []
    end
  end

  def inventory_update
    new_stocks = []
    update_stocks = []
    date = params[:date]
    stocks_once_update_params.each do |stock_param|
      end_day_stock = stock_param[1][:end_day_stock]
      if end_day_stock.present?
        material_id = stock_param[0]
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
      prev_stock = material.stocks.order("date DESC").first
      if prev_stock
        @material_stock[material.id] = [material,prev_stock.end_day_stock]
      else
        @material_stock[material.id] = [material,0]
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

  def history
    material_id = params[:material_id]
    @material = Material.find(material_id)
    today = Date.today
    @stocks_hash = Stock.where(material_id:material_id,date:(today - 10)..(today + 10)).map{|stock|[stock.date, stock]}.to_h
    if @stocks_hash.keys.include?(today)
      @dates = @stocks_hash.keys.sort
    else
      @dates = @stocks_hash.keys.push(today).sort
    end
    @unit = Material.find(material_id).order_unit
  end

  private
  def stock_create_update
    params.require(:stock).permit(:date,:material_id,:start_day_stock,:end_day_stock,:used_amount,:delivery_amount,:inventory_flag)
  end
  def stocks_once_update_params
    params.require(:stock)
  end

end
