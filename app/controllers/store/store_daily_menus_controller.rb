class Store::StoreDailyMenusController < ApplicationController
  def index
    if params[:start_date].present?
      date = params[:start_date]
    else
      date = Date.today
    end
    @store_daily_menus = StoreDailyMenu.where(store_id:current_user.store.id,start_time:date.in_time_zone.all_month).includes(store_daily_menu_details:[:product])
  end
  def show
    @store_daily_menu = StoreDailyMenu.find(params[:id])
    @date = @store_daily_menu.start_time
    @tommoroww = StoreDailyMenu.find_by(start_time:@date+1)
    @yesterday = StoreDailyMenu.find_by(start_time:@date-1)
    @store_daily_menu_details = @store_daily_menu.store_daily_menu_details.includes(:product)
  end
  def edit
    @store_daily_menu = StoreDailyMenu.find(params[:id])
  end
  def update
    @store_daily_menu = StoreDailyMenu.find(params[:id])
    respond_to do |format|
      if @store_daily_menu.update(store_daily_menu_params)
        format.html { redirect_to [:store,@store_daily_menu], notice: 'Daily menu was successfully updated.' }
        format.json { render :show, status: :ok, location: @store_daily_menu }
      else
        format.html { render :edit }
        format.json { render json: @store_daily_menu.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    def store_daily_menu_params
      params.require(:store_daily_menu).permit(:start_time,:total_num,:weather,:max_temperature,:min_temperature,
        store_daily_menu_details_attributes: [:id,:store_daily_menu_id,:product_id,:number,:row_order])
    end
end
