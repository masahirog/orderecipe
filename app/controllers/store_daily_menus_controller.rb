class StoreDailyMenusController < AdminController
  before_action :set_store_daily_menu, only: [:show, :edit, :update, :destroy]

  def index
    if params[:start_date].present?
      date = params[:start_date]
    elsif params[:start_time].present?
      date = params[:start_time]
    else
      date = Date.today
    end
    store_id = params[:store_id]
    @store = Store.find(store_id)
    if params['one_day_flag'] == 'true'
      @store_daily_menus = @store.store_daily_menus.where(start_time:date).includes(store_daily_menu_details:[:product])
    else
      @store_daily_menus = @store.store_daily_menus.where(start_time:date.in_time_zone.all_month).includes(store_daily_menu_details:[:product])
    end
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "#{date}_#{store_id}_shukei.csv", type: :csv
      end
    end
  end

  def show
    @store_daily_menu = StoreDailyMenu.find(params[:id])
    @date = @store_daily_menu.start_time
    @tommoroww = StoreDailyMenu.find_by(start_time:@date+1)
    @yesterday = StoreDailyMenu.find_by(start_time:@date-1)
    @store_daily_menu_details = @store_daily_menu.store_daily_menu_details.includes(:product)
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "#{@date}_#{@store_daily_menu.store_id}_shokuhinhyouzi.csv", type: :csv
      end
    end
  end

  def edit
    daily_menu = @store_daily_menu.daily_menu
    dmd_product_ids = daily_menu.products.ids - @store_daily_menu.products.ids
    @dmd_products = Product.where(id:dmd_product_ids)
  end

  def update
    respond_to do |format|
      if @store_daily_menu.update(store_daily_menu_params)
        format.html { redirect_to @store_daily_menu, notice: 'Store daily menu was successfully updated.' }
        format.json { render :show, status: :ok, location: @store_daily_menu }
      else
        format.html { render :edit }
        format.json { render json: @store_daily_menu.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @store_daily_menu.destroy
    respond_to do |format|
      format.html { redirect_to _store_daily_menus_url, notice: 'Store daily menu was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def once_edit
    @sdmd_product = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @store_daily_menu = StoreDailyMenu.find(params[:id])
    from = params[:from]
    to = params[:to]
    @store_dayily_menus = StoreDailyMenu.includes(:store_daily_menu_details).where(start_time:[from..to],store_id:@store_daily_menu.store_id)
    product_ids = @store_dayily_menus.map{|sdm|sdm.store_daily_menu_details.map{|sdmt|sdmt.product_id}}.flatten.uniq
    @products = Product.where(id:product_ids)
    @store_dayily_menus.each do |sdm|
      sdm.store_daily_menu_details.each do |sdmd|
        @sdmd_product[[sdm.id,sdmd.product_id]]=[sdmd.id,sdmd.number]
      end
    end
  end
  def once_update
    sdmds = []
    store_id = params[:store_id]
    store_daily_menu_ids = params['store_daily_menu_ids'].split(' ')
    params[:sdmd].each do |sdmd|
      store_daily_menu_detail = StoreDailyMenuDetail.find(sdmd[0])
      store_daily_menu_detail.number = sdmd[1]
      sdmds << store_daily_menu_detail
    end
    StoreDailyMenuDetail.import sdmds, on_duplicate_key_update:[:number]
    StoreDailyMenu.where(id:store_daily_menu_ids).each do |sdm|
      sum = sdm.store_daily_menu_details.sum(:number)
      sdm.update_attributes(total_num:sum)
    end
    redirect_to store_daily_menus_path(store_id:store_id), notice: "まとめて更新しました"
  end

  private

    def set_store_daily_menu
      @store_daily_menu = StoreDailyMenu.find(params[:id])
    end


    def store_daily_menu_params
      params.require(:store_daily_menu).permit(:start_time,:total_num,:weather,:max_temperature,:min_temperature,
        store_daily_menu_details_attributes: [:id,:store_daily_menu_id,:product_id,:number,:row_order,:_destroy,:actual_inventory,:add_stocked,:use_stock,:sold_out_flag])
    end
end
