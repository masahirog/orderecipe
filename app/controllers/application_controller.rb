class ApplicationController < ActionController::Base
  # http_basic_authenticate_with :name => ENV['BASIC_AUTH_USERNAME'], :password => ENV['BASIC_AUTH_PASSWORD'] if Rails.env == "production"
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_action :authenticate_user!

  protect_from_forgery with: :exception
  before_action :stock_alert_materials

  def after_sign_in_path_for(resource)
    if current_user.id == 1
      root_url
    else
      mobile_inventory_stocks_path
    end
  end
  def render_500(e)
    ExceptionNotifier.notify_exception(e, :env => request.env, :data => {:message => "your error message"})
    render template: 'errors/error_500', status: 500
  end

  def shift
    @months = [['1月',1],['2月',2],['3月',3],['4月',4],['5月',5],['6月',6],
              ['7月',7],['8月',8],['9月',9],['10月',10],['11月',11],['12月',12]]
    if params[:month]
      month = params[:month]
    else
      month = Date.today.month
      params[:month] = month
    end
    sheet_name = "#{month}月"
    session = GoogleDrive::Session.from_config("config.json")
    sheet = session.spreadsheet_by_key("1ekgHswr8Pg9H0eTYvXGiDGLA7Vog2BJv5ftZ04jwn18").worksheet_by_title(sheet_name)
    if sheet.present?
      last_row = sheet.num_rows
      @tables = []
      for i in 1..last_row do
        if sheet[i,1] == "-"
        else
          row = []
          for ii in 2..34 do
            row << sheet[i, ii]
          end
          @tables << row
        end
      end
    else
      redirect_to '/shift', notice: "#{month}月のシフトが存在しません。" and return
    end
    render :layout => false
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
    def stock_alert_materials
      @stock_alert_materials = Material.where(need_inventory_flag:true).count
    end
end
