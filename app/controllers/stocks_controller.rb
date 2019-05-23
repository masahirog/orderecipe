class StocksController < ApplicationController
  def index
    date = params[:date]
    @stocks = Stock.where(date:date)
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

  private
  def stock_create_update
    params.require(:stock).permit(:date,stock_materials_attributes: [:id, :stock_id,:amount, :material_id, :_destroy])
  end
end
