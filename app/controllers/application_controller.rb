class ApplicationController < ActionController::Base
  # http_basic_authenticate_with :name => ENV['BASIC_AUTH_USERNAME'], :password => ENV['BASIC_AUTH_PASSWORD'] if Rails.env == "production"
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_action :authenticate_user!
  protect_from_forgery with: :exception

  def render_500(e)
    ExceptionNotifier.notify_exception(e, :env => request.env, :data => {:message => "your error message"})
    render template: 'errors/error_500', status: 500
  end
  def sell_reports
    today = Date.today
    if params[:from]
      from = params[:from]
    else
      from = today - 30
    end
    if params[:to]
      to = params[:to]
    else
      to = today + 30
    end
    kurumesi_orders = KurumesiOrder.where(start_time:from..to,canceled_flag:false).where('management_id > ?',0).order(start_time:"DESC")
    kurumesi_order_details = KurumesiOrderDetail.joins(:kurumesi_order,:product).where(:kurumesi_orders => {id:kurumesi_orders.ids})
    @date_counts = kurumesi_orders.group(:start_time).count
    @date_numbers = kurumesi_order_details.where(:products => {product_category:1}).group('kurumesi_orders.start_time').sum(:number)
    @date_brand_counts = kurumesi_order_details.where(:products => {product_category:1}).group('kurumesi_orders.start_time').group('kurumesi_orders.brand_id').count
    @date_brand_sums = kurumesi_order_details.where(:products => {product_category:1}).group('kurumesi_orders.start_time').group('kurumesi_orders.brand_id').sum(:number)
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "#{Time.now.strftime('%Y%m%d')}_kurumesi_data.csv", type: :csv
      end
    end
  end


  def kpi
    @dates = []
    @date_sum_py = []
    gon.date_sum = []
    gon.mokuhyo = []
    gon.idoheikin = []
    gon.masu_date_sum = []
    gon.masu_mokuhyo = []
    gon.masu_idoheikin = []

    gon.hasi_date_sum = []
    gon.hasi_mokuhyo = []
    gon.hasi_idoheikin = []

    gon.don_date_sum = []
    gon.don_mokuhyo = []
    gon.don_idoheikin = []

    gon.suzu_date_sum = []
    gon.suzu_mokuhyo = []
    gon.suzu_idoheikin = []

    @to = Date.today
    from = @to - 100
    kurumesi_order_ids = KurumesiOrder.where(start_time:(from..@to),canceled_flag:false).where('management_id > ?',0).ids

    kurumesi_order_details = KurumesiOrderDetail.joins(:kurumesi_order,:product).where(:kurumesi_orders => {id:kurumesi_order_ids})
    masu_order_details = KurumesiOrderDetail.joins(:kurumesi_order,:product).where(:kurumesi_orders => {id:kurumesi_order_ids,brand_id:11})
    hasi_order_details = KurumesiOrderDetail.joins(:kurumesi_order,:product).where(:kurumesi_orders => {id:kurumesi_order_ids,brand_id:21})
    don_order_details = KurumesiOrderDetail.joins(:kurumesi_order,:product).where(:kurumesi_orders => {id:kurumesi_order_ids,brand_id:31})
    suzu_order_details = KurumesiOrderDetail.joins(:kurumesi_order,:product).where(:kurumesi_orders => {id:kurumesi_order_ids,brand_id:51})

    kurumesi_make_num = kurumesi_order_details.where(:products => {product_category:1}).group('kurumesi_orders.start_time').sum(:number)
    masu_make_num = masu_order_details.where(:products => {product_category:1}).group('kurumesi_orders.start_time').sum(:number)
    hasi_make_num = hasi_order_details.where(:products => {product_category:1}).group('kurumesi_orders.start_time').sum(:number)
    don_make_num = don_order_details.where(:products => {product_category:1}).group('kurumesi_orders.start_time').sum(:number)
    suzu_make_num = suzu_order_details.where(:products => {product_category:1}).group('kurumesi_orders.start_time').sum(:number)

    (from..@to).each do |date|
      if kurumesi_make_num[date].present?
        gon.date_sum << kurumesi_make_num[date]
        @date_sum_py << kurumesi_make_num[date]
        if masu_make_num[date].present?
          gon.masu_date_sum << masu_make_num[date]
        else
          gon.masu_date_sum << 0
        end
        if hasi_make_num[date].present?
          gon.hasi_date_sum << hasi_make_num[date]
        else
          gon.hasi_date_sum << 0
        end
        if don_make_num[date].present?
          gon.don_date_sum << don_make_num[date]
        else
          gon.don_date_sum << 0
        end
        if suzu_make_num[date].present?
          gon.suzu_date_sum << suzu_make_num[date]
        else
          gon.suzu_date_sum << 0
        end
        @dates << Time.parse(date.to_s).to_i
        gon.mokuhyo << 850
        gon.masu_mokuhyo << 300
        gon.hasi_mokuhyo << 100
      end
    end
    gon.date_sum.each_cons(10) do |arr|
      gon.idoheikin << arr.sum/arr.length
    end
    gon.masu_date_sum.each_cons(10) do |arr|
      gon.masu_idoheikin << arr.sum/arr.length
    end
    gon.hasi_date_sum.each_cons(10) do |arr|
      gon.hasi_idoheikin << arr.sum/arr.length
    end
    gon.don_date_sum.each_cons(10) do |arr|
      gon.don_idoheikin << arr.sum/arr.length
    end
    gon.suzu_date_sum.each_cons(10) do |arr|
      gon.suzu_idoheikin << arr.sum/arr.length
    end

    latest_heikin = gon.idoheikin.last
    @tasseiritsu = ((latest_heikin.to_f / 850)*100).round(1)
  end

  def product_report

  end

  protected
    def revert_link
      view_context.link_to('取消', revert_version_path(@material.versions.last), :method => :post)
    end
    def versions_link
      view_context.link_to('編集履歴', version_path(@material), :method => :get)
    end
    def revert_link_menu
      view_context.link_to('取消', revert_version_path(@menu.versions.last), :method => :post)
    end
end
