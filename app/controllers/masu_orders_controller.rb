class MasuOrdersController < ApplicationController
  before_action :set_masu_order, only: [ :edit, :update, :destroy]

  def manufacturing_sheet
    date = params[:date]
    @masu_orders = MasuOrder.includes(masu_order_details:[:product]).where(start_time:date,canceled_flag:false).order(:pick_time)
    # @bentos_num_h = @masu_orders.joins(:masu_order_details).group('masu_order_details.product_id').sum('masu_order_details.number')
    @bentos_num_h = @masu_orders.joins(masu_order_details:[:product]).where(:products => {product_category:1}).group('masu_order_details.product_id').sum('masu_order_details.number')
    @masu_orders_num_h = @masu_orders.joins(masu_order_details:[:product]).where(:products => {product_category:1}).group('masu_order_details.masu_order_id').sum('masu_order_details.number')
    respond_to do |format|
      format.html
      format.pdf do
        pdf = MasuOrderManufacturingSheetPdf.new(@bentos_num_h,date,@masu_orders,@masu_orders_num_h)
        pdf.font "vendor/assets/fonts/ipaexm.ttf"
        send_data pdf.render,
        filename:    "#{date}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end
  def loading_sheet
    date = params[:date]
    @masu_orders = MasuOrder.includes(masu_order_details:[:product]).where(start_time:date,canceled_flag:false).order(:pick_time)
    # @bentos_num_h = @masu_orders.joins(masu_order_details:[:product]).where(:products => {product_category:1}).group('masu_order_details.product_id').sum('masu_order_details.number')
    @masu_orders_num_h = @masu_orders.joins(masu_order_details:[:product]).where(:products => {product_category:1}).group('masu_order_details.masu_order_id').sum('masu_order_details.number')
    @products_num_h = @masu_orders.joins(masu_order_details:[:product]).group('masu_order_details.product_id').sum('masu_order_details.number')
    # @masu_order_details = MasuOrderDetail.joins(masu_order:[:product]).where(:masu_orders => {id:@masu_orders.ids}).order('product.product_category')
    respond_to do |format|
      format.html
      format.pdf do
        pdf = MasuOrderLoadingSheetPdf.new(date,@masu_orders,@masu_orders_num_h,@products_num_h)
        pdf.font "vendor/assets/fonts/ipaexm.ttf"
        send_data pdf.render,
        filename:    "#{date}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end
  def receipt
  end
  def print_receipt
    date = params[:date]
    total = params[:total].to_i.to_s(:delimited)
    to = params[:to]
    keisho = params[:keisho]
    tadashi = params[:tadashi]
    uchiwake = params[:uchiwake]
    data = [date,to,keisho,total,tadashi,uchiwake]
    respond_to do |format|
      format.html
      format.pdf do
        pdf = MasuOrderReceiptPdf.new(data)
        pdf.font "vendor/assets/fonts/ipaexm.ttf"
        send_data pdf.render,
        filename:    "#{date}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end
  def index
    @products = Product.where(brand_id:11)
    @date_order_count = MasuOrder.where(canceled_flag:false).group('start_time').count
    @date_canceled_order_count = MasuOrder.where(canceled_flag:true).group('start_time').count
    @date_group = MasuOrderDetail.joins(:masu_order,:product).where(:masu_orders => {canceled_flag:false}).group('masu_orders.start_time').group('products.id').sum(:number)
    @date_sum = MasuOrderDetail.joins(:masu_order,:product).where(:masu_orders => {canceled_flag:false}).group('masu_orders.start_time').sum(:number)
  end

  def date
    date = params[:date]
    @masu_orders = MasuOrder.includes(masu_order_details:[:product]).where(start_time:date,canceled_flag:false).order(:pick_time)
    @canceled_masu_orders = MasuOrder.includes(masu_order_details:[:product]).where(start_time:date,canceled_flag:true).order(:pick_time)
    @bentos_num_h = @masu_orders.joins(masu_order_details:[:product]).where(:products => {product_category:1}).group('masu_order_details.product_id').sum('masu_order_details.number')
    @masu_orders_num_h = @masu_orders.joins(masu_order_details:[:product]).where(:products => {product_category:1}).group('masu_order_details.masu_order_id').sum('masu_order_details.number')
  end
  def show
    @masu_order = MasuOrder.includes(masu_order_details:[:product]).find(params[:id])
  end

  def print_preparation
    mochiba = params[:mochiba]
    date = params[:date]
    masu_orders = MasuOrder.includes(masu_order_details:[:product]).where(start_time:date,canceled_flag:false).order(:pick_time)
    @bentos_num_h = masu_orders.joins(masu_order_details:[:product]).where(:products => {product_category:1}).group('masu_order_details.product_id').sum('masu_order_details.number')
    respond_to do |format|
      format.html
      format.pdf do
        pdf = MasuOrderPdf.new(@bentos_num_h,date,mochiba)
        pdf.font "vendor/assets/fonts/ipaexm.ttf"
        send_data pdf.render,
        filename:    "#{date}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end

  def new
    @products = Product.where(brand_id:11)
    @masu_order = MasuOrder.new
    @masu_order.masu_order_details.build
  end

  def edit
    @products = Product.where(brand_id:11)
  end

  def create
    @products = Product.where(brand_id:11)
    if params['masu_order']["pick_time(4i)"]==''||params['masu_order']["pick_time(5i)"]==''
      @masu_order = MasuOrder.new(masu_order_picktimenone_params)
    else
      @masu_order = MasuOrder.new(masu_order_params)
    end
    if @masu_order.save
      redirect_to date_masu_orders_path(date:@masu_order.start_time), notice: 'Masu order was successfully created.'
    else
      render :new
    end
  end

  def update
    @products = Product.where(brand_id:11)
    if params['masu_order']["pick_time(4i)"]==''||params['masu_order']["pick_time(5i)"]==''
      if @masu_order.update(masu_order_picktimenone_params)
        redirect_to date_masu_orders_path(date:@masu_order.start_time), notice: 'Masu order was successfully updated.'
      else
        render :edit
      end
    else
      if @masu_order.update(masu_order_params)
        redirect_to date_masu_orders_path(date:@masu_order.start_time), notice: 'Masu order was successfully updated.'
      else
        render :edit
      end
    end
  end

  def destroy
    @masu_order.destroy
    respond_to do |format|
      format.html { redirect_to masu_orders_url, notice: 'Masu order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_masu_order
      @masu_order = MasuOrder.find(params[:id])
    end

    def masu_order_picktimenone_params
      params.require(:masu_order).permit(:start_time,:kurumesi_order_id,:canceled_flag,:payment,
        masu_order_details_attributes: [:id,:masu_order_id,:product_id,:number,:_destroy])
    end

    def masu_order_params
      params.require(:masu_order).permit(:start_time,:kurumesi_order_id,:pick_time,:canceled_flag,:payment,
        masu_order_details_attributes: [:id,:masu_order_id,:product_id,:number,:_destroy])
    end
end
