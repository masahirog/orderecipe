class Crew::StoreDailyMenusController < ApplicationController
  def index
    @store = Store.find(params[:store_id])
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
    @store = @store_daily_menu.store
    @date = @store_daily_menu.start_time
    @tommoroww = StoreDailyMenu.find_by(store_id:@store.id,start_time:@date+1)
    @yesterday = StoreDailyMenu.find_by(store_id:@store.id,start_time:@date-1)
    @store_daily_menu_details = @store_daily_menu.store_daily_menu_details.order("row_order ASC").includes(product:[:product_ozara_serving_informations])
    @after_store_daily_menus = StoreDailyMenu.where('start_time >= ?',@date).where(store_id:@store.id).order(:start_time)
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "#{@date}_#{@store.id}_shokuhinhyouzi.csv", type: :csv
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
  def edit

    @store_daily_menu = StoreDailyMenu.find(params[:id])
    daily_menu = @store_daily_menu.daily_menu
    default_product_ids = [14624,14634,14644,14654,14664,14674]
    dmd_product_ids = daily_menu.products.ids + default_product_ids - @store_daily_menu.products.ids
    @dmd_products = Product.where(id:dmd_product_ids)
    saveble_photo_nums = 3 - @store_daily_menu.store_daily_menu_photos.length
    saveble_photo_nums.times {
      @store_daily_menu.store_daily_menu_photos.build
    }
    @date = @store_daily_menu.start_time
    @tommoroww = DailyMenu.find_by(start_time:@date+1)
    @yesterday = DailyMenu.find_by(start_time:@date-1)
    @products = Product.where(brand_id:111)
    @store_daily_menu_details = @store_daily_menu.products
  end
  def update
    @store_daily_menu = StoreDailyMenu.find(params[:id])
    respond_to do |format|
      if @store_daily_menu.update(store_daily_menu_params)
        format.html { redirect_to crew_store_daily_menu_path(@store_daily_menu), notice: '更新しました' }
      else
        format.html { render :edit }
      end
    end
  end
  private


    def store_daily_menu_params
      params.require(:store_daily_menu).permit(:start_time,:total_num,:weather,:max_temperature,:min_temperature,:opentime_showcase_photo,:event,:store_id,:daily_menu_id,
        :showcase_photo_a,:showcase_photo_b,:signboard_photo,:opentime_showcase_photo_uploaded,
        store_daily_menu_photos_attributes: [:id,:store_daily_menu_id,:image],
        store_daily_menu_details_attributes: [:id,:store_daily_menu_id,:product_id,:number,:row_order,:_destroy,
          :actual_inventory,:carry_over,:sold_out_flag,:serving_plate_id,:signboard_flag,
          :window_pop_flag,:stock_deficiency_excess,:sozai_number,:bento_fukusai_number])
    end
end
