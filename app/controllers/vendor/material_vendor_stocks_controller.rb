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
    @before_month_stock = MaterialVendorStock.order("date DESC").where("date < ?",@date.beginning_of_month).where(material_id:params[:material_id]).limit(1)[0]
    @bom_month_stock = MaterialVendorStock.find_by(date:@date.beginning_of_month,material_id:params[:material_id])
    @dates_stocks = MaterialVendorStock.where(date:@dates,material_id:params[:material_id]).map{|mvs|[mvs.date,mvs]}.to_h
    # @material = Material.find(params[:material_id])
  end
  def index
    if params[:month].present?
      @date = "#{params[:month]}-01".to_date
      @month = params[:month]
    else
      @date = Date.today
      @month = "#{@date.year}-#{sprintf("%02d",@date.month)}"
    end
    @dates =(@date.beginning_of_month..@date.end_of_month).to_a
    if current_user.admin == true
      @vendors = Vendor.where(id:params[:vendor_id])
    else
      @vendors = Vendor.where(user_id:current_user.id)
    end
    @materials = Material.where(vendor_id:@vendors.ids,unused_flag:false)
    materials_hash = @materials.map{|material|[material.id,material]}.to_h
    @prev_hash = {}
    @bom_hash = {}
    @material_date_order_amount = OrderMaterial.joins(:order).where(:orders =>{fixed_flag:true}).where(delivery_date:@dates,material_id:@materials.ids,un_order_flag:false).group(:material_id,:delivery_date).sum(:order_quantity)
    @material_date_order_amount.each do |mtoa|
      material = materials_hash[mtoa[0][0]]
      amount = number_with_precision((mtoa[1].to_f/material.recipe_unit_quantity)*material.order_unit_quantity,precision:1, strip_insignificant_zeros: true, delimiter: ',')
      @material_date_order_amount[mtoa[0]] = amount
    end

    MaterialVendorStock.order("date ASC").where("date < ?",@date.beginning_of_month).where(material_id:@materials.ids).each do |mvs|
      @prev_hash[mvs.material_id] = mvs
    end
    MaterialVendorStock.order("date ASC").where(date:@date.beginning_of_month).where(material_id:@materials.ids).each do |mvs|
      @bom_hash[mvs.material_id] = mvs
    end
    @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    MaterialVendorStock.where(date:@dates,material_id:@materials.ids).each do |mvs|
      @hash[mvs.material_id][mvs.date] = mvs
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
    @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @previous_end_day_stock = {}
    @end_day_stock = {}
    respond_to do |format|
      if @material_vendor_stock.save
        @date = @material_vendor_stock.date
        material_id = @material_vendor_stock.material_id
        @material = Material.find(material_id)
        @previous_end_day_stock[material_id] = @material_vendor_stock.previous_end_day_stock
        @end_day_stock[material_id] = @material_vendor_stock.end_day_stock
        future_material_vendor_stocks = MaterialVendorStock.order("date asc").where("date >= ?",@date).where(material_id:material_id)
        future_material_vendor_stocks.each_with_index do |fmvs,i|
          unless i == 0
            previous_end_day_stock = @end_day_stock[material_id]
            end_day_stock = previous_end_day_stock.to_i + fmvs.new_stock_amount.to_i - fmvs.shipping_amount.to_i
            fmvs.update(end_day_stock:end_day_stock,previous_end_day_stock:previous_end_day_stock)
          end
          @hash[material_id][fmvs.date] = fmvs
        end
        @material_date_order_amount = OrderMaterial.joins(:order).where(:orders =>{fixed_flag:true}).where("delivery_date >= ?",@date).where(material_id:material_id,un_order_flag:false).group(:material_id,:delivery_date).sum(:order_quantity)
        @material_date_order_amount.each do |mtoa|
          amount = number_with_precision((mtoa[1].to_f/@material.recipe_unit_quantity)*@material.order_unit_quantity,precision:1, strip_insignificant_zeros: true, delimiter: ',')
          @material_date_order_amount[mtoa[0]] = amount
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
    @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @previous_end_day_stock = {}
    @end_day_stock = {}
    eds = 0
    respond_to do |format|
      if @material_vendor_stock.update(vendor_material_vendor_stock_params)
        @date = @material_vendor_stock.date
        material_id = @material_vendor_stock.material_id
        @material = Material.find(material_id)
        @previous_end_day_stock[material_id] = @material_vendor_stock.previous_end_day_stock
        @end_day_stock[material_id] = @material_vendor_stock.end_day_stock
        future_material_vendor_stocks = MaterialVendorStock.order("date asc").where("date >= ?",@date).where(material_id:material_id)
        future_material_vendor_stocks.each_with_index do |fmvs,i|
          if i==0
            eds = @end_day_stock[material_id]
          else
            previous_end_day_stock = eds
            eds = previous_end_day_stock.to_i + fmvs.new_stock_amount.to_i - fmvs.shipping_amount.to_i
            fmvs.update(end_day_stock:eds,previous_end_day_stock:previous_end_day_stock)
          end
          @hash[material_id][fmvs.date] = fmvs
        end
        @material_date_order_amount = OrderMaterial.joins(:order).where(:orders =>{fixed_flag:true}).where("delivery_date >= ?",@date).where(material_id:material_id,un_order_flag:false).group(:material_id,:delivery_date).sum(:order_quantity)
        @material_date_order_amount.each do |mtoa|
          amount = number_with_precision((mtoa[1].to_f/@material.recipe_unit_quantity)*@material.order_unit_quantity,precision:1, strip_insignificant_zeros: true, delimiter: ',')
          @material_date_order_amount[mtoa[0]] = amount
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
      params.require(:material_vendor_stock).permit(:id,:material_id,:date,:end_day_stock,:shipping_amount,:new_stock_amount,:previous_end_day_stock,:estimated_amount)
      # params.require(:material_vendor_stock)[:shipping_amount] = 0 if params.require(:material_vendor_stock)[:shipping_amount].blank?
      # params.require(:material_vendor_stock)[:new_stock_amount] = 0 if params.require(:material_vendor_stock)[:new_stock_amount].blank?
      # params.require(:material_vendor_stock)[:estimated_amount] = 0 if params.require(:material_vendor_stock)[:estimated_amount].blank?

    end
end
