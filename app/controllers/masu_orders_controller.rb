class MasuOrdersController < ApplicationController
  before_action :set_masu_order, only: [ :edit, :update, :destroy]

  def test
    require 'net/imap'
    require 'kconv'
    require 'mail'

    # imapに接続
    imap_host = 'imap.gmail.com' # imapをgmailのhostに設定する
    imap_usessl = true # imapのsslを有効にする
    imap_port = 993 # ssl有効なら993、そうでなければ143
    imap = Net::IMAP.new(imap_host, imap_port, imap_usessl)
    # imapにログイン
    imap_user = 'gon@bento.jp'
    imap_passwd = 'rohisama'
    imap.login(imap_user, imap_passwd)
    #info@kurumesi-bentou.com
    search_criterias = [
      'FROM','gon@bento.jp',
      'SINCE', (Date.today).strftime("%d-%b-%Y")
    ]

    imap.select('INBOX') # 対象のメールボックスを選択
    ids = imap.search(search_criterias) # 全てのメールを取得
    ids.each_slice(100).to_a.each do |id_block| # 100件ごとにメールをfetchする
      imap.fetch(id_block, "RFC822").each do |mail|
        m = Mail.new(mail.attr["RFC822"])
        subject = m.subject
        recieved_datetime = m.date
        if m.multipart?
          if m.text_part
            body = m.text_part.decoded
          elsif m.html_part
            body = m.html_part.decoded
          end
        else
          body = m.body.decoded.encode("UTF-8", m.charset)
        end

        unless KurumesiMail.where(subject:subject,recieved_datetime:recieved_datetime).present?
          @kurumei_mail = KurumesiMail.new
          @kurumei_mail.subject = subject
          @kurumei_mail.body = body
          @kurumei_mail.recieved_datetime = recieved_datetime
          # kurumei_mailの作成
          if subject.include?("ご注文がありました")
            @kurumei_mail.status = 1
            order_info_from_mail = KurumesiMail.input_order(body)
            unless MasuOrder.where(kurumesi_order_id:order_info_from_mail[:kurumesi_order_id]).present?
              @masu_order = MasuOrder.new
              @masu_order.start_time = order_info_from_mail[:delivery_date]
              @masu_order.kurumesi_order_id = order_info_from_mail[:kurumesi_order_id]
              @masu_order.payment = order_info_from_mail[:pay]
              @masu_order.miso = order_info_from_mail[:miso]
              @masu_order.number = order_info_from_mail[:order_details].sum { |hash| hash[:num]}
              @masu_order.trash_bags = order_info_from_mail[:trash_bags]
              @masu_order.tea = order_info_from_mail[:tea]
              order_info_from_mail[:order_details].each do |od|
                @masu_order.masu_order_details.build(product_id:od[:product_id],number:od[:num])
              end
              if @masu_order.save
                @kurumei_mail.masu_order_id = @masu_order.id
                @kurumei_mail.masu_order_reflect_flag = true
              else
                @kurumei_mail.masu_order_reflect_flag = false
              end
              @kurumei_mail.save
            end
          elsif subject.include?("変更致しました")
            @kurumei_mail.status = 2
            order_info_from_mail = KurumesiMail.input_order(body)
            @masu_order = MasuOrder.find_by(kurumesi_order_id:order_info_from_mail[:kurumesi_order_id])
            #詳細をすべて一旦削除
            @masu_order.masu_order_details.destroy_all

            @masu_order.start_time = order_info_from_mail[:delivery_date]
            @masu_order.payment = order_info_from_mail[:pay]
            @masu_order.miso = order_info_from_mail[:miso]
            @masu_order.number = order_info_from_mail[:order_details].sum { |hash| hash[:num]}
            @masu_order.trash_bags = order_info_from_mail[:trash_bags]
            @masu_order.tea = order_info_from_mail[:tea]
            order_info_from_mail[:order_details].each do |od|
              @masu_order.masu_order_details.build(product_id:od[:product_id],number:od[:num])
            end
            if @masu_order.save
              @kurumei_mail.masu_order_id = @masu_order.id
              @kurumei_mail.masu_order_reflect_flag = true
            else
              @kurumei_mail.masu_order_reflect_flag = false
            end
            @kurumei_mail.save


          elsif subject.include?("キャンセルさせて頂きました")
            @kurumei_mail.status = 3
            order_info_from_mail = KurumesiMail.input_order(body)
            @masu_order = MasuOrder.find_by(kurumesi_order_id:order_info_from_mail[:kurumesi_order_id])
            @masu_order.cancel_flag = true
            if @masu_order.save
              @kurumei_mail.masu_order_id = @masu_order.id
              @kurumei_mail.masu_order_reflect_flag = true
            else
              @kurumei_mail.masu_order_reflect_flag = false
            end
            @kurumei_mail.save
          end
        end
      end
    end
  end
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
        @masu_order.update(pick_time:nil) if params['masu_order']["pick_time(4i)"]==''||params['masu_order']["pick_time(5i)"]=''
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
