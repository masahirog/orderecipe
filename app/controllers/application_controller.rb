class ApplicationController < ActionController::Base
  # http_basic_authenticate_with :name => ENV['BASIC_AUTH_USERNAME'], :password => ENV['BASIC_AUTH_PASSWORD'] if Rails.env == "production"
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_action :authenticate_user!
  protect_from_forgery with: :exception
  add_flash_types :success, :info, :warning, :danger
  before_action :user_check
  def user_check
    @today = Date.today
    if user_signed_in?
      @group_id = current_user.group_id
      @stores = Group.find(@group_id).stores
    end
  end

  def after_sign_in_path_for(resource)
    if current_user.admin?
      root_url
    elsif current_user.id == 49
      shifts_path(group_id:current_user.group_id)
    elsif current_user.id == 69
      crew_stores_path
    end
  end
  def render_500(e)
    ExceptionNotifier.notify_exception(e, :env => request.env, :data => {:message => "your error message"})
    render template: 'errors/error_500', status: 500
  end
  # def outside_view
  #   if params[:from].present?
  #     @from = Date.parse(params[:from])
  #   else
  #     @from = Date.today + 1
  #   end
  #   if params[:to].present?
  #     @to = Date.parse(params[:to])
  #   else
  #     @to = @from + 6
  #   end
  #   @dates =(@from..@to).to_a
  #   if @dates.count > 7
  #     @from = Date.today
  #     @to = @from + 6
  #     @dates =(@from..@to).to_a
  #     flash[:alert] = '期間は7日以内で選択してください。'
  #   end
  #   store_id = 39
  #   vendor_ids = [151,489]
  #   stocks = Stock.joins(:material).where(store_id:store_id).where(:materials => {vendor_id:vendor_ids}).where(date:@from..@to)
  #   @hash = {}
  #   stocks.each do |stock|
  #     amount = ActiveSupport::NumberHelper.number_to_rounded((stock.used_amount/stock.material.accounting_unit_quantity), strip_insignificant_zeros: true, :delimiter => ',', precision: 1)
  #     @hash[[stock.material_id,stock.date]] = amount
  #   end
  #   material_ids = stocks.map{|stock|stock.material_id}.uniq
  #   stock_hash = {}
  #   @materials = Material.where(id:material_ids).order(short_name:'asc')
  #   @used_amounts = {}
  #   Stock.where(material_id:material_ids).where(date:@from..@to).each do |stock|
  #     if @used_amounts[stock.material_id].present?
  #       @used_amounts[stock.material_id] += (stock.used_amount / stock.material.accounting_unit_quantity)
  #     else
  #       @used_amounts[stock.material_id] = (stock.used_amount / stock.material.accounting_unit_quantity)
  #     end
  #   end
  #   render :layout => false
  # end


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
