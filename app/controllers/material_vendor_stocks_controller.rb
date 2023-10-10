class MaterialVendorStocksController < ApplicationController
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
    @vendor = Vendor.find(params[:vendor_id])
    @materials = Material.where(vendor_id:@vendor.id,unused_flag:false)
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
    @material_vendor_stock = MaterialVendorStock.new(material_vendor_stock_params)

    respond_to do |format|
      if @material_vendor_stock.save
        format.html { redirect_to material_vendor_stock_url(@material_vendor_stock), notice: "Material vendor stock was successfully created." }
        format.json { render :show, status: :created, location: @material_vendor_stock }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @material_vendor_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @material_vendor_stock.update(material_vendor_stock_params)
        format.html { redirect_to material_vendor_stock_url(@material_vendor_stock), notice: "Material vendor stock was successfully updated." }
        format.json { render :show, status: :ok, location: @material_vendor_stock }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @material_vendor_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @material_vendor_stock.destroy

    respond_to do |format|
      format.html { redirect_to material_vendor_stocks_url, notice: "Material vendor stock was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_material_vendor_stock
      @material_vendor_stock = MaterialVendorStock.find(params[:id])
    end

    def material_vendor_stock_params
      params.fetch(:material_vendor_stock, {})
    end
end
