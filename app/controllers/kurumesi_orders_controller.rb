class KurumesiOrdersController < ApplicationController
  before_action :set_kurumesi_order, only: [ :edit, :update, :destroy]

  def manufacturing_sheet
    date = params[:date]
    @kurumesi_orders = KurumesiOrder.includes(kurumesi_order_details:[:product]).where(start_time:date,canceled_flag:false).order(:pick_time)
    # @bentos_num_h = @kurumesi_orders.joins(:kurumesi_order_details).group('kurumesi_order_details.product_id').sum('kurumesi_order_details.number')
    @bentos_num_h = @kurumesi_orders.joins(kurumesi_order_details:[:product]).where(:products => {product_category:1}).group('kurumesi_order_details.product_id').sum('kurumesi_order_details.number')
    @kurumesi_orders_num_h = @kurumesi_orders.joins(kurumesi_order_details:[:product]).where(:products => {product_category:1}).group('kurumesi_order_details.kurumesi_order_id').sum('kurumesi_order_details.number')
    respond_to do |format|
      format.html
      format.pdf do
        pdf = KurumesiOrderManufacturingSheetPdf.new(@bentos_num_h,date,@kurumesi_orders,@kurumesi_orders_num_h)
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
    @kurumesi_orders = KurumesiOrder.includes(kurumesi_order_details:[:product]).where(start_time:date,canceled_flag:false).order(:pick_time)
    # @bentos_num_h = @kurumesi_orders.joins(kurumesi_order_details:[:product]).where(:products => {product_category:1}).group('kurumesi_order_details.product_id').sum('kurumesi_order_details.number')
    @kurumesi_orders_num_h = @kurumesi_orders.joins(kurumesi_order_details:[:product]).where(:products => {product_category:1}).group('kurumesi_order_details.kurumesi_order_id').sum('kurumesi_order_details.number')
    @products_num_h = @kurumesi_orders.joins(kurumesi_order_details:[:product]).group('kurumesi_order_details.product_id').sum('kurumesi_order_details.number')
    # @kurumesi_order_details = KurumesiOrderDetail.joins(kurumesi_order:[:product]).where(:kurumesi_orders => {id:@kurumesi_orders.ids}).order('product.product_category')
    respond_to do |format|
      format.html
      format.pdf do
        pdf = KurumesiOrderLoadingSheetPdf.new(date,@kurumesi_orders,@kurumesi_orders_num_h,@products_num_h)
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
        pdf = KurumesiOrderReceiptPdf.new(data)
        pdf.font "vendor/assets/fonts/ipaexm.ttf"
        send_data pdf.render,
        filename:    "#{date}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end

  def invoice
  end
  def print_invoice
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
        pdf = KurumesiOrderReceiptPdf.new(data)
        pdf.font "vendor/assets/fonts/ipaexm.ttf"
        send_data pdf.render,
        filename:    "#{date}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end


  def index
    @memo_orders = KurumesiOrder.where.not(memo:nil).where.not(memo:'').group('start_time').count
    @products = Product.where(brand_id:11)
    @date_order_count = KurumesiOrder.where(canceled_flag:false).group('start_time').count
    @date_canceled_order_count = KurumesiOrder.where(canceled_flag:true).group('start_time').count
    @date_group = KurumesiOrderDetail.joins(:kurumesi_order,:product).where(:kurumesi_orders => {canceled_flag:false}).where(:products => {product_category:1}).group('kurumesi_orders.start_time').group('products.id').sum(:number)
    @date_sum = KurumesiOrderDetail.joins(:kurumesi_order,:product).where(:kurumesi_orders => {canceled_flag:false}).where(:products => {product_category:1}).group('kurumesi_orders.start_time').sum(:number)
    @miso_num = KurumesiOrderDetail.joins(:kurumesi_order,:product).where(:kurumesi_orders => {canceled_flag:false}).where(:products => {id:3831}).group('kurumesi_orders.start_time').sum(:number)
    @cantea_num = KurumesiOrderDetail.joins(:kurumesi_order,:product).where(:kurumesi_orders => {canceled_flag:false}).where(:products => {id:3801}).group('kurumesi_orders.start_time').sum(:number)
    @pettea_num = KurumesiOrderDetail.joins(:kurumesi_order,:product).where(:kurumesi_orders => {canceled_flag:false}).where(:products => {id:3791}).group('kurumesi_orders.start_time').sum(:number)
  end

  def date
    date = params[:date]
    @kurumesi_orders = KurumesiOrder.includes(kurumesi_order_details:[:product]).where(start_time:date,canceled_flag:false).order(:pick_time,:created_at)
    @canceled_kurumesi_orders = KurumesiOrder.includes(kurumesi_order_details:[:product]).where(start_time:date,canceled_flag:true).order(:pick_time)
    @bentos_num_h = @kurumesi_orders.joins(kurumesi_order_details:[:product]).where(:products => {product_category:1}).group('kurumesi_order_details.product_id').sum('kurumesi_order_details.number')
    @kurumesi_orders_num_h = @kurumesi_orders.joins(kurumesi_order_details:[:product]).where(:products => {product_category:1}).group('kurumesi_order_details.kurumesi_order_id').sum('kurumesi_order_details.number')
  end
  def show
    @kurumesi_order = KurumesiOrder.includes(kurumesi_order_details:[:product]).find(params[:id])
  end

  def print_preparation
    mochiba = params[:mochiba]
    date = params[:date]
    kurumesi_orders = KurumesiOrder.includes(kurumesi_order_details:[:product]).where(start_time:date,canceled_flag:false).order(:pick_time)
    @bentos_num_h = kurumesi_orders.joins(kurumesi_order_details:[:product]).where(:products => {product_category:1}).group('kurumesi_order_details.product_id').sum('kurumesi_order_details.number')
    respond_to do |format|
      format.html
      format.pdf do
        pdf = KurumesiOrderPdf.new(@bentos_num_h,date,mochiba)
        pdf.font "vendor/assets/fonts/ipaexm.ttf"
        send_data pdf.render,
        filename:    "#{date}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end

  def material_preparation
    mochiba = params[:mochiba]
    date = params[:date]
    kurumesi_orders = KurumesiOrder.includes(kurumesi_order_details:[:product]).where(start_time:date,canceled_flag:false).order(:pick_time)
    @bentos_num_h = kurumesi_orders.joins(kurumesi_order_details:[:product]).where(:products => {product_category:1}).group('kurumesi_order_details.product_id').sum('kurumesi_order_details.number')
    respond_to do |format|
      format.html
      format.pdf do
        pdf = MaterialPreparation.new(@bentos_num_h,date,mochiba)
        pdf.font "vendor/assets/fonts/ipaexm.ttf"
        send_data pdf.render,
        filename:    "#{date}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end
  def new
    @products = Product.all
    @kurumesi_order = KurumesiOrder.new
    @kurumesi_order.kurumesi_order_details.build
    @brands = Brand.all
  end

  def edit
    @products = Product.all
    @brands = Brand.all
  end

  def create
    @products = Product.all
    if params['kurumesi_order']["pick_time(4i)"]==''||params['kurumesi_order']["pick_time(5i)"]==''
      @kurumesi_order = KurumesiOrder.new(kurumesi_order_picktimenone_params)
    else
      @kurumesi_order = KurumesiOrder.new(kurumesi_order_params)
    end
    if @kurumesi_order.save
      redirect_to date_kurumesi_orders_path(date:@kurumesi_order.start_time), notice: 'Masu order was successfully created.'
    else
      render :new
    end
  end

  def update
    @products = Product.where(brand_id:11)
    if params['kurumesi_order']["pick_time(4i)"]==''||params['kurumesi_order']["pick_time(5i)"]==''
      if @kurumesi_order.update(kurumesi_order_picktimenone_params)
        redirect_to date_kurumesi_orders_path(date:@kurumesi_order.start_time), notice: 'Masu order was successfully updated.'
      else
        render :edit
      end
    else
      if @kurumesi_order.update(kurumesi_order_params)
        redirect_to date_kurumesi_orders_path(date:@kurumesi_order.start_time), notice: 'Masu order was successfully updated.'
      else
        render :edit
      end
    end
  end

  def destroy
    @kurumesi_order.destroy
    respond_to do |format|
      format.html { redirect_to kurumesi_orders_url, notice: 'Masu order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def change_brands
    brand_id = params[:brand_id]
    @products = Product.where(brand_id:brand_id)
  end

  private
    def set_kurumesi_order
      @kurumesi_order = KurumesiOrder.find(params[:id])
    end

    def kurumesi_order_picktimenone_params
      params.require(:kurumesi_order).permit(:start_time,:management_id,:canceled_flag,:payment,:memo,:brand_id,
        kurumesi_order_details_attributes: [:id,:kurumesi_order_id,:product_id,:number,:_destroy])
    end

    def kurumesi_order_params
      params.require(:kurumesi_order).permit(:start_time,:management_id,:pick_time,:canceled_flag,:payment,:brand_id,
        :memo,kurumesi_order_details_attributes: [:id,:kurumesi_order_id,:product_id,:number,:_destroy])
    end
end
