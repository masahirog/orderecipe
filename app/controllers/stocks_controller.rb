class StocksController < ApplicationController
  def index
    arr = []
    date = params[:date]
    stocks = Stock.where(date:date).map{|stock|[stock.material_id,[stock.used_amount,stock.delivery_amount,stock.start_day_stock,stock.end_day_stock]]}.to_h
    storage_location_id = params[:storage_location_id]
    @storage_locations = StorageLocation.all
    @materials = Material.search(params).where(end_of_sales:false).includes(:vendor,:storage_location).page(params[:page]).per(30)
    @materials.each do |material|
      if stocks[material.id].present?
        used_amount = stocks[material.id][0]
        delivery_amount = stocks[material.id][1]
        start_day_stock = stocks[material.id][3]
        end_day_stock = stocks[material.id][4]
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
    new_stocks = []
    date = params[:date]
    @vendors = Vendor.all
    materials = Material.includes(:vendor).where(end_of_sales: 0)
    @materials = []
    stocks_hash = Stock.where(date:date).map{|stock|[stock.material_id,stock]}.to_h
    materials.each do |material|
      new_stocks << Stock.new(date:date,material_id:material.id) unless stocks_hash[material.id].present?
    end
    Stock.import new_stocks if new_stocks.present?
    @stocks = Stock.where(date:date)
  end
  def edit
    @stock = Stock.includes(stock_materials:[material:[:vendor]]).find(params[:id])
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
       redirect_to @stock
     else
       render 'new'
     end
  end


  def update
    @stock = Stock.includes(stock_materials:[:material]).find(params[:id])
    respond_to do |format|
      if @stock.update(stock_create_update)
        format.html { redirect_to @stock, notice: '更新OK' }
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
    @materials = Material.search(params).where(end_of_sales:false).includes(:vendor,:storage_location).page(params[:page]).per(30)
    @stocks_hash = Stock.where(date:date,material_id:@materials.ids).map{|stock|[stock.material_id,stock]}.to_h
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
          update_stocks << stock
          # change_stock(update_stocks,material_id,date,end_day_stock)
        else
          prev_stock = Stock.where("date < ?", date).where(material_id:material_id).order("date DESC").first
          if prev_stock.present?
            new_stocks << Stock.new(material_id:material_id,date:date,end_day_stock:end_day_stock,start_day_stock:prev_stock.end_day_stock)
          else
            new_stocks << Stock.new(material_id:material_id,date:date,end_day_stock:end_day_stock)
          end
        end
      end
    end
    Stock.import new_stocks if new_stocks.present?
    Stock.import update_stocks, on_duplicate_key_update:[:end_day_stock] if update_stocks.present?

    redirect_to inventory_stocks_path(date:date,page:params[:page],storage_location_id:params[:storage_location_id],vendor_id:params[:vendor_id]),
    notice: "<div class='alert alert-success' role='alert' style='font-size:15px;'>在庫を保存しました！</div>".html_safe
  end


  private
  def stock_create_update
    params.require(:stock).permit(:date,stock_materials_attributes: [:id, :stock_id,:amount, :material_id, :_destroy])
  end
  def stocks_once_update_params
    params.require(:stock)
  end

end
