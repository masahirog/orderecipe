class Crew::StoreDailyMenusController < ApplicationController
  def index
    @store = current_user.store
    if params[:start_date].present?
      date = params[:start_date]
    else
      date = Date.today
    end
    @store_daily_menus = @store.store_daily_menus.where(start_time:date.in_time_zone.all_month).includes(store_daily_menu_details:[:product])
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "#{date}_#{@store.id}_shukei.csv", type: :csv
      end
    end
  end
  def show
    @store_daily_menu = StoreDailyMenu.find(params[:id])
    store_id = @store_daily_menu.store_id
    date = @store_daily_menu.start_time
    @date = @store_daily_menu.start_time
    @tommoroww = StoreDailyMenu.find_by(store_id:store_id,start_time:@date+1)
    @yesterday = StoreDailyMenu.find_by(store_id:store_id,start_time:@date-1)
    @store_daily_menu_details = @store_daily_menu.store_daily_menu_details.order("row_order ASC").includes(product:[:product_ozara_serving_informations])
    @after_store_daily_menus = StoreDailyMenu.where('start_time >= ?',date).where(store_id:store_id).order(:start_time)
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "#{@date}_#{@store_daily_menu.store_id}_shokuhinhyouzi.csv", type: :csv
      end
      format.pdf do
        pdf = StoreDailyMenuPdf.new(@store_daily_menu.id)
        send_data pdf.render,
        filename:    "#{@store_daily_menu.id}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end
end
