class ApplicationController < ActionController::Base
  # http_basic_authenticate_with :name => ENV['BASIC_AUTH_USERNAME'], :password => ENV['BASIC_AUTH_PASSWORD'] if Rails.env == "production"
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_action :authenticate_user!, if: :use_auth?
  protect_from_forgery with: :exception
  add_flash_types :success, :info, :warning, :danger
  before_action :user_check
  def user_check
    @today = Date.today
    if user_signed_in? && current_user.group_id.present?
      @stores = current_user.group.stores.where(store_type:0)
    end
  end

  def after_sign_in_path_for(resource)
    if current_user.admin?
      root_url
    elsif current_user.id == 49
      shifts_path(group_id:current_user.group_id,store_type:0)
    elsif current_user.id == 69
      crew_stores_path
    elsif current_user.vendor_flag == true
      vendor_orders_path
    end
  end
  def render_500(e)
    ExceptionNotifier.notify_exception(e, :env => request.env, :data => {:message => "your error message"})
    render template: 'errors/error_500', status: 500
  end
  def list
    if params[:month].present?
      @date = "#{params[:month]}-01".to_date
      @month = params[:month]
      if @date < Date.parse('2024-01-01')
        flash[:notice] = "2024年1月以降を選択してください"
        @date = @today
        @month = "#{@date.year}-#{sprintf("%02d",@date.month)}"
      end
    else
      @date = @today
      @month = "#{@date.year}-#{sprintf("%02d",@date.month)}"
    end
    dates =(@date.beginning_of_month..@date.end_of_month).to_a
    @wednesdays = []
    dates.each do |date|
      @wednesdays << date if date.wday == 3
    end
    @daily_menus = DailyMenu.includes(daily_menu_details:[:product]).where(start_time:@wednesdays)
    render :layout => false
  end

  def shibataya
    if params[:date]
      @date = Date.parse(params[:date])
      if @date < @today || @today + 3 < @date
        @date = @today
      end
    else
      @date = @today
    end
    @daily_menu = DailyMenu.find_by(start_time:@date)
    product_ids = []
    @daily_menu.daily_menu_details.includes([:product]).each do |dmd|
      product_ids << dmd.product_id if dmd.product.product_category == "お弁当" || dmd.product.product_category == "ご飯・丼" || dmd.product.product_category == "惣菜" ||dmd.product.product_category == "スイーツ・ドリンク"
    end
    @pre_order = PreOrder.new
    product_ids.each do |product_id|
      @pre_order.pre_order_products.build(product_id:product_id,order_num:0)
    end
    @stores = Store.where(id:[9,19,29,154,164])
    @times = []
    (11..20).each do |h|
      ["00","15","30","45"].each do |m|
        @times << "#{h}:#{m}"
      end
    end
    
    render :layout => false
  end
  def shibataya_howto
    render :layout => false
  end
  def shibataya_orders
    if params[:date]
      @date = Date.parse(params[:date])
    else
      @date = @today
    end
    @pre_orders = PreOrder.includes(:store,:pre_order_products).where(date:@date)
    render :layout => false
  end


  private

  def use_auth?
    unless controller_name == 'pre_orders' || action_name == 'shibataya'|| action_name == 'shibataya_orders'|| action_name == 'shibataya_howto'
      true
    end
  end      
  protected
    # def revert_link
    #   view_context.link_to('取消', revert_version_path(@material.versions.last), :method => :post)
    # end
    # def versions_link
    #   view_context.link_to('編集履歴', version_path(@material), :method => :get)
    # end
    # def revert_link_menu
    #   view_context.link_to('取消', revert_version_path(@menu.versions.last), :method => :post)
    # end

end
