class MasuOrdersController < ApplicationController
  before_action :set_masu_order, only: [ :edit, :update, :destroy]

  def manufacturing_sheet
    date = params[:date]
    @masu_orders = MasuOrder.includes(masu_order_details:[:product]).where(start_time:date).order(:pick_time)
    @products_num_h = @masu_orders.joins(:masu_order_details).group('masu_order_details.product_id').sum('masu_order_details.number')
    respond_to do |format|
      format.html
      format.pdf do
        pdf = MasuOrderManufacturingSheetPdf.new(@products_num_h,date)
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
    @masu_orders = MasuOrder.includes(masu_order_details:[:product]).where(start_time:date).order(:pick_time)
    @products_num_h = @masu_orders.joins(:masu_order_details).group('masu_order_details.product_id').sum('masu_order_details.number')
    respond_to do |format|
      format.html
      format.pdf do
        pdf = MasuOrderLoadingSheetPdf.new(@products_num_h,date)
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
    @products = Product.where(product_type:'枡々')
    @masu_orders = MasuOrder.all
    @date_order_count = MasuOrder.group('start_time').count
    @date_group = MasuOrderDetail.joins(:masu_order,:product).group('masu_orders.start_time').group('products.id').sum(:number)
    @date_sum = MasuOrderDetail.joins(:masu_order,:product).group('masu_orders.start_time').sum(:number)
  end

  def date
    date = params[:date]
    @masu_orders = MasuOrder.includes(masu_order_details:[:product]).where(start_time:date).order(:pick_time)
    @products_num_h = @masu_orders.joins(:masu_order_details).group('masu_order_details.product_id').sum('masu_order_details.number')
  end
  def show
    @masu_order = MasuOrder.includes(masu_order_details:[:product]).find(params[:id])
  end

  def print_preparation
    mochiba = params[:mochiba]
    date = params[:date]
    masu_orders = MasuOrder.includes(masu_order_details:[:product]).where(start_time:date).order(:pick_time)
    @products_num_h = masu_orders.joins(:masu_order_details).group('masu_order_details.product_id').sum('masu_order_details.number')
    respond_to do |format|
      format.html
      format.pdf do
        pdf = MasuOrderPdf.new(@products_num_h,date,mochiba)
        pdf.font "vendor/assets/fonts/ipaexm.ttf"
        send_data pdf.render,
        filename:    "#{date}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end

  def new
    @products = Product.where(product_type:'枡々')
    @masu_order = MasuOrder.new
    @masu_order.masu_order_details.build
  end

  def edit
    @products = Product.where(product_type:'枡々')
  end

  def create
    @masu_order = MasuOrder.new(masu_order_params)
    @products = Product.where(product_type:'枡々')
    respond_to do |format|
      if @masu_order.save
        format.html { redirect_to masu_orders_path, notice: 'Masu order was successfully created.' }
        format.json { render :show, status: :created, location: @masu_order }
      else
        format.html { render :new }
        format.json { render json: @masu_order.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @products = Product.where(product_type:'枡々')
    respond_to do |format|
      if @masu_order.update(masu_order_params)
        format.html { redirect_to date_masu_orders_path(date:@masu_order.start_time), notice: 'Masu order was successfully updated.' }
        format.json { render :show, status: :ok, location: @masu_order }
      else
        format.html { render :edit }
        format.json { render json: @masu_order.errors, status: :unprocessable_entity }
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

    def masu_order_params
      params.require(:masu_order).permit(:start_time,:number,:kurumesi_order_id,:pick_time,:fixed_flag,:payment,:miso,:tea,
        :trash_bags,masu_order_details_attributes: [:id,:masu_order_id,:product_id,:number,:_destroy])
    end
end
