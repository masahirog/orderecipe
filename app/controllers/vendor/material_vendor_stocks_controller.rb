class Vendor::MaterialVendorStocksController < ApplicationController
  before_action :set_material_vendor_stock, only: %i[ show edit update destroy ]
  def material
    if params[:date].present?
      @date = params[:date].to_date
    else
      @date = @today
    end
    @previous_month = @date.prev_month
    @next_month = @date.next_month
    @dates = (@date.beginning_of_month..@date.end_of_month).to_a
    @latest_stock = MaterialVendorStock.order("date DESC").where("date <= ?",@date).where(material_id:params[:material_id]).limit(1)[0]
    @before_month_stock = MaterialVendorStock.order("date DESC").where("date < ?",@date.beginning_of_month).where(material_id:params[:material_id]).limit(1)[0]
    @bom_month_stock = MaterialVendorStock.find_by(date:@date.beginning_of_month,material_id:params[:material_id])
    @dates_stocks = MaterialVendorStock.where(date:@dates,material_id:params[:material_id]).map{|mvs|[mvs.date,mvs]}.to_h
    @material = Material.find(params[:material_id])
  end
  def index
    @vendors = Vendor.where(user_id:current_user.id)
    @materials = Material.where(vendor_id:@vendors.ids,unused_flag:false)
    @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @materials.each do |material|
      @hash[material.id][:latest_material_vendor_stock] = MaterialVendorStock.where("date <= ?",@today).where(material_id:material.id).order("date DESC").limit(1)
    end
  end

  def show
  end

  def new
    @material_vendor_stock = MaterialVendorStock.new
  end

  def edit
  end

  def create
    @material_vendor_stock = MaterialVendorStock.new(vendor_material_vendor_stock_params)
    shipping_amount = params[:material_vendor_stock][:shipping_amount].to_i
    new_stock_amount = params[:material_vendor_stock][:new_stock_amount].to_i
    @material_vendor_stock.end_day_stock = @material_vendor_stock.previous_end_day_stock + new_stock_amount - shipping_amount
    @dates_stocks = {}
    respond_to do |format|
      if @material_vendor_stock.save
        @date = @material_vendor_stock.date
        material_id = @material_vendor_stock.material_id
        @material = Material.find(material_id)
        @previous_end_day_stock = @material_vendor_stock.previous_end_day_stock
        end_day_stock = @material_vendor_stock.end_day_stock
        future_material_vendor_stocks = MaterialVendorStock.order("date asc").where("date >= ?",@date).where(material_id:material_id)
        future_material_vendor_stocks.each_with_index do |fmvs,i|
          unless i == 0
            previous_end_day_stock = end_day_stock
            end_day_stock = previous_end_day_stock + fmvs.new_stock_amount - fmvs.shipping_amount
            fmvs.update(end_day_stock:end_day_stock,previous_end_day_stock:previous_end_day_stock)            
          end
          @dates_stocks[fmvs.date] = fmvs
        end
        format.html { redirect_to vendor_material_vendor_stock_url(@material_vendor_stock), notice: "Material vendor stock was successfully created." }
        format.js
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @material_vendor_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    shipping_amount = params[:material_vendor_stock][:shipping_amount].to_i
    new_stock_amount = params[:material_vendor_stock][:new_stock_amount].to_i
    params[:material_vendor_stock][:end_day_stock] = @material_vendor_stock.previous_end_day_stock + new_stock_amount - shipping_amount
    @dates_stocks = {}
    respond_to do |format|
      if @material_vendor_stock.update(vendor_material_vendor_stock_params)
        @date = @material_vendor_stock.date
        material_id = @material_vendor_stock.material_id
        @material = Material.find(material_id)
        @previous_end_day_stock = @material_vendor_stock.previous_end_day_stock
        end_day_stock = @material_vendor_stock.end_day_stock
        future_material_vendor_stocks = MaterialVendorStock.order("date asc").where("date >= ?",@date).where(material_id:material_id)
        future_material_vendor_stocks.each_with_index do |fmvs,i|
          unless i == 0
            previous_end_day_stock = end_day_stock
            end_day_stock = previous_end_day_stock + fmvs.new_stock_amount - fmvs.shipping_amount
            fmvs.update(end_day_stock:end_day_stock,previous_end_day_stock:previous_end_day_stock)
          end
          @dates_stocks[fmvs.date] = fmvs
        end
        format.html { redirect_to vendor_material_vendor_stock_url(@material_vendor_stock), notice: "Material vendor stock was successfully updated." }
        format.js
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @material_vendor_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @material_vendor_stock.destroy

    respond_to do |format|
      format.html { redirect_to vendor_material_vendor_stocks_url, notice: "Material vendor stock was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_material_vendor_stock
      @material_vendor_stock = MaterialVendorStock.find(params[:id])
    end

    def vendor_material_vendor_stock_params
      params.require(:material_vendor_stock).permit(:id,:material_id,:date,:end_day_stock,:shipping_amount,:new_stock_amount,:previous_end_day_stock)
    end
end
