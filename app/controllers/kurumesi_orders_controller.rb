class KurumesiOrdersController < ApplicationController
  before_action :set_kurumesi_order, only: [ :edit, :update, :destroy]
  def collation_sheet
    date = params[:date]
    @kurumesi_orders = KurumesiOrder.includes(:brand).where(start_time:date,canceled_flag:false).order(:pick_time)
    respond_to do |format|
      format.html
      format.pdf do
        pdf = KurumesiCollation.new(date,@kurumesi_orders)
        send_data pdf.render,
        filename:    "#{date}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end

  def loading_sheet
    date = params[:date]
    @kurumesi_orders = KurumesiOrder.where(start_time:date,canceled_flag:false).order(:pick_time)
    @kurumesi_orders_num_h = @kurumesi_orders.joins(kurumesi_order_details:[:product]).where(:products => {product_category:1}).group('kurumesi_order_details.kurumesi_order_id').sum('kurumesi_order_details.number')
    @products_num_h = @kurumesi_orders.joins(kurumesi_order_details:[:product]).group('kurumesi_order_details.product_id').sum('kurumesi_order_details.number')
    @brand_ids = @kurumesi_orders.map{|kurumesi_order|kurumesi_order.brand_id}.uniq
    respond_to do |format|
      format.html
      format.pdf do
        pdf = KurumesiLoadingPdf.new(date,@kurumesi_orders,@kurumesi_orders_num_h,@products_num_h,@brand_ids)

        send_data pdf.render,
        filename:    "#{date}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end
  def make_order
    date = params[:date]
    @kurumesi_orders = KurumesiOrder.where(start_time:date,canceled_flag:false).order(:pick_time)
    @kurumesi_orders_num_h = @kurumesi_orders.joins(kurumesi_order_details:[:product]).where(:products => {product_category:1}).group('kurumesi_order_details.kurumesi_order_id').sum('kurumesi_order_details.number')
    @products_num_h = @kurumesi_orders.joins(kurumesi_order_details:[:product]).group('kurumesi_order_details.product_id').sum('kurumesi_order_details.number')
    @brand_ids = @kurumesi_orders.map{|kurumesi_order|kurumesi_order.brand_id}.uniq
    respond_to do |format|
      format.html
      format.pdf do
        pdf = KurumesiMakeOrderPdf.new(date,@kurumesi_orders,@kurumesi_orders_num_h,@products_num_h,@brand_ids)

        send_data pdf.render,
        filename:    "#{date}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end
  def equipment
    date = params[:date]
    @kurumesi_orders = KurumesiOrder.where(start_time:date,canceled_flag:false).order(:pick_time)
    @kurumesi_orders_num_h = @kurumesi_orders.joins(kurumesi_order_details:[:product]).where(:products => {product_category:1}).group('kurumesi_order_details.kurumesi_order_id').sum('kurumesi_order_details.number')
    @products_num_h = @kurumesi_orders.joins(kurumesi_order_details:[:product]).group('kurumesi_order_details.product_id').sum('kurumesi_order_details.number')
    @brand_ids = @kurumesi_orders.map{|kurumesi_order|kurumesi_order.brand_id}.uniq
    respond_to do |format|
      format.html
      format.pdf do
        pdf = KurumesiEquipmentPdf.new(date,@kurumesi_orders,@kurumesi_orders_num_h,@products_num_h,@brand_ids)

        send_data pdf.render,
        filename:    "#{date}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end
  def paper_print

    # redirect_to date_kurumesi_orders_path(date:date)
  end
  def print_receipts
    date = params[:date]
    data_arr = []
    kurumesi_orders = KurumesiOrder.where(start_time:date,payment:[1,2],canceled_flag:false).where.not(management_id:0)
    kurumesi_orders.each do |ko|
      to = ko.reciept_name
      keisho = "御中"
      total = ko.total_price.to_i.to_s(:delimited)
      tadashi = ko.proviso
      uchiwake = ''
      data = [date,to,keisho,total,tadashi,uchiwake]
      data_arr << data
    end
    respond_to do |format|
      format.html
      format.pdf do
        pdf = ReceiptsPdf.new(data_arr)

        send_data pdf.render,
        filename:    "#{date}_receipt.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end
  def mail_check
    KurumesiMail.routine_check
    redirect_to kurumesi_orders_path, notice: 'くるめしのメールを確認しました。'
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
        pdf = ReceiptPdf.new(data)

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
        pdf = ReceiptPdf.new(data)

        send_data pdf.render,
        filename:    "#{date}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end


  def index
    if params[:start_date].present?
      date = params[:start_date]
    else
      date = Date.today
    end
    kurumesi_order_details = KurumesiOrderDetail.joins(:kurumesi_order,:product).where(:kurumesi_orders => {canceled_flag:false,start_time: date.in_time_zone.all_month})
    @memo_orders = KurumesiOrder.where.not(memo:nil,start_time: date.in_time_zone.all_month).where.not(memo:'').group('start_time').count
    @products = Product.all
    @date_order_count = KurumesiOrder.where(canceled_flag:false,start_time: date.in_time_zone.all_month).group('start_time').count
    @date_canceled_order_count = KurumesiOrder.where(canceled_flag:true,start_time: date.in_time_zone.all_month).group('start_time').count
    @unconfirmed_order_count = KurumesiOrder.where(canceled_flag:false,start_time: date.in_time_zone.all_month,confirm_flag:false).group('start_time').count
    @brands_count = KurumesiOrder.where(canceled_flag:false,start_time: date.in_time_zone.all_month).group('start_time').count('DISTINCT brand_id')
    @products_count = kurumesi_order_details.where(:products => {product_category:1}).group('kurumesi_orders.start_time').count('DISTINCT product_id')
    @date_group = kurumesi_order_details.where(:products => {product_category:1}).group('kurumesi_orders.start_time').group('products.id').sum(:number)
    @date_sum = kurumesi_order_details.where(:products => {product_category:1}).group('kurumesi_orders.start_time').sum(:number)
    @am_sum = kurumesi_order_details.where(:kurumesi_orders => {delivery_time:'00:00:00'..'11:59:00'}).where(:products => {product_category:1}).group('kurumesi_orders.start_time').sum(:number)
    @pm_sum = kurumesi_order_details.where(:kurumesi_orders => {delivery_time:'12:00:00'..'23:59:00'}).where(:products => {product_category:1}).group('kurumesi_orders.start_time').sum(:number)
    @miso_num = kurumesi_order_details.where(:products => {id:3831}).group('kurumesi_orders.start_time').sum(:number)
    @cantea_num = kurumesi_order_details.where(:products => {id:3801}).group('kurumesi_orders.start_time').sum(:number)
    @pettea_num = kurumesi_order_details.where(:products => {id:3791}).group('kurumesi_orders.start_time').sum(:number)
    @brands = Brand.all
  end

  def date
    # Dotenv.overload
    s3 = Aws::S3::Resource.new(
      region: 'ap-northeast-1',
      credentials: Aws::Credentials.new(
        ENV['ACCESS_KEY_ID'],
        ENV['SECRET_ACCESS_KEY']
      )
    )
    signer = Aws::S3::Presigner.new(client: s3.client)
    @presigned_url = {}
    date = params[:date]
    @year = date[0..3]
    @month = date[5..6]
    @day = date[8..9]
    @kurumesi_orders = KurumesiOrder.where(start_time:date,canceled_flag:false).order(:pick_time,:created_at)
    @canceled_kurumesi_orders = KurumesiOrder.where(start_time:date,canceled_flag:true).order(:pick_time)
    @bentos_num_h = @kurumesi_orders.joins(kurumesi_order_details:[:product]).where(:products => {product_category:1}).group('products.brand_id').group('kurumesi_order_details.product_id').sum('kurumesi_order_details.number').sort {|(k1, v1), (k2, v2)| k1[0] <=> k2[0] }
    @kurumesi_orders_num_h = @kurumesi_orders.joins(kurumesi_order_details:[:product]).where(:products => {product_category:1}).group('kurumesi_order_details.kurumesi_order_id').sum('kurumesi_order_details.number')
    @brands = Brand.all
    arr = []
    @kurumesi_orders.includes(:brand).each do |ko|
      arr << [ko.brand.store_id,ko.management_id,ko.payment]
      @presigned_url[ko.id] = signer.presigned_url(:get_object,bucket: 'kurumesi-check', key: "#{ko.management_id}.jpg", expires_in: 60)
    end
    gon.order_arr = arr
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
        pdf = KurumesiPreperationPdf.new(@bentos_num_h,date,mochiba)

        send_data pdf.render,
        filename:    "#{date}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end

  def print_preparation_roma
    mochiba = params[:mochiba]
    date = params[:date]
    kurumesi_orders = KurumesiOrder.includes(kurumesi_order_details:[:product]).where(start_time:date,canceled_flag:false).order(:pick_time)
    @bentos_num_h = kurumesi_orders.joins(kurumesi_order_details:[:product]).where(:products => {product_category:1}).group('kurumesi_order_details.product_id').sum('kurumesi_order_details.number')
    respond_to do |format|
      format.html
      format.pdf do
        pdf = KurumesiOrderPdf.new(@bentos_num_h,date,mochiba)

        send_data pdf.render,
        filename:    "#{date}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end

  def material_preparation
    if params[:mochiba] == "1"
      mochiba = '切出し'
    else
      mochiba = '調理場'
    end

    if params[:lang] == "1"
      lang = '日本語'
    else
      lang = 'ローマ字'
    end
    date = params[:date]
    kurumesi_orders = KurumesiOrder.includes(kurumesi_order_details:[:product]).where(start_time:date,canceled_flag:false).order(:pick_time)
    @bentos_num_h = kurumesi_orders.joins(kurumesi_order_details:[:product]).where(:products => {product_category:1}).group('kurumesi_order_details.product_id').sum('kurumesi_order_details.number')
    respond_to do |format|
      format.html
      format.pdf do
        pdf = MaterialPreparation.new(@bentos_num_h,date,mochiba,lang)

        send_data pdf.render,
        filename:    "#{date}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end
  def new
    @kurumesi_order = KurumesiOrder.new(brand_id:params[:brand_id],start_time:params[:date])
    @kurumesi_order.kurumesi_order_details.build
    @brand_name = Brand.find(params[:brand_id]).name
    @products = Product.where(brand_id:[params[:brand_id],41],status:"販売中")

  end

  def edit
    brand_id = @kurumesi_order.brand_id
    @products = Product.where(brand_id:[brand_id,41],status:"販売中")
    @brand_name = Brand.find(brand_id).name
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
      @kurumesi_order.update(kurumesi_order_picktimenone_params)
      respond_to do |format|
        format.html { redirect_to date_kurumesi_orders_path(date:@kurumesi_order.start_time), notice: '更新しました！' }
        format.js
      end
    else
      @kurumesi_order.update(kurumesi_order_params)
      respond_to do |format|
        format.html { redirect_to date_kurumesi_orders_path(date:@kurumesi_order.start_time), notice: '更新しました！' }
        format.js
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

  def today_check
    date = params[:date]
    if params[:lang] == "1"
      lang = '日本語'
    else
      lang = 'ローマ字'
    end
    kurumesi_orders = KurumesiOrder.order(:pick_time).includes(:kurumesi_order_details).where(start_time:date,canceled_flag:false)
    @bentos_num_h = {}
    kurumesi_orders.each do |ko|
      ko.kurumesi_order_details.each do |kod|
        if @bentos_num_h[kod.product_id].present?
          @bentos_num_h[kod.product_id] += kod.number
        else
          @bentos_num_h[kod.product_id] = kod.number
        end
      end
    end
    respond_to do |format|
      format.html
      format.pdf do
        pdf = KurumesiPreperationTodayCheck.new(@bentos_num_h,date,lang)

        send_data pdf.render,
        filename:    "#{date}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end

  private
    def set_kurumesi_order
      @kurumesi_order = KurumesiOrder.find(params[:id])
    end

    def kurumesi_order_picktimenone_params
      params.require(:kurumesi_order).permit(:start_time,:management_id,:canceled_flag,:payment,:memo,:brand_id,:confirm_flag,
        :delivery_time,:company_name,:staff_name,:delivery_address,:reciept_name,:proviso,:total_price,:kitchen_memo,:special_response_flag,
        kurumesi_order_details_attributes: [:id,:kurumesi_order_id,:product_id,:number,:_destroy])
    end

    def kurumesi_order_params
      params.require(:kurumesi_order).permit(:start_time,:management_id,:pick_time,:canceled_flag,:payment,:brand_id,:confirm_flag,
        :delivery_time,:company_name,:staff_name,:delivery_address,:reciept_name,:proviso,:total_price,:kitchen_memo,:special_response_flag,
        :memo,kurumesi_order_details_attributes: [:id,:kurumesi_order_id,:product_id,:number,:_destroy])
    end
end
