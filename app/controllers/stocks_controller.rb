class StocksController < ApplicationController
  def index
    @stocks = Stock.all
  end
  def new
    @vendors = Vendor.all
    @materials = Material.includes(:vendor).where(end_of_sales: 0).where(stock_management: 1)
    @stock = Stock.new
    @stock.stock_materials.build
    render :new, layout: false
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

  private
  def stock_create_update
    params.require(:stock).permit(:date,stock_materials_attributes: [:amount, :stock_id, :material_id, :_destroy])
  end
end
