class ApplicationController < ActionController::Base
  # http_basic_authenticate_with :name => ENV['BASIC_AUTH_USERNAME'], :password => ENV['BASIC_AUTH_PASSWORD'] if Rails.env == "production"
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_action :authenticate_user!, except: [:list]
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
