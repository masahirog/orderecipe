class StocksController < ApplicationController
  def index
    @stocks = Stock.all
  end
  def new
    @stock = Stock.new
    @vendors = Vendor.all
    materials = Material.includes(:vendor).where(end_of_sales: 0)
    materials.each do |material|
      @stock.stock_materials.build(material_id:material.id,amount:0)
    end
  end
  def edit
    @stock = Stock.includes(stock_materials:[material:[:vendor]]).find(params[:id])
    @vendors = Vendor.all
  end
  def show
    @stock = Stock.find(params[:id])
  end
  def material_info
    @material = Material.find(params[:id])
    respond_to do |format|
      format.html
      format.json
    end
  end
  def create
    @stock = Stock.create(stock_create_update)
     if @stock.save
       redirect_to @stock
     else
       render 'new'
     end
  end


  def update
    @stock = Stock.find(params[:id])
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
    params.require(:stock).permit(:date,stock_materials_attributes: [:amount, :stock_id, :material_id, :_destroy])
  end
end
