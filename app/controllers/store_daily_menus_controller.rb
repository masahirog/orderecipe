class StoreDailyMenusController < AdminController
  before_action :set_store_daily_menu, only: [:show, :edit, :update, :destroy]

  def index
    store_id = params[:store_id]
    store = Store.find(store_id)
    @store_daily_menus = store.store_daily_menus
  end

  def show
    @store_daily_menu = StoreDailyMenu.find(params[:id])
    @date = @store_daily_menu.start_time
    @tommoroww = StoreDailyMenu.find_by(start_time:@date+1)
    @yesterday = StoreDailyMenu.find_by(start_time:@date-1)
    @store_daily_menu_details = @store_daily_menu.store_daily_menu_details.includes(:product)
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

  private

    def set_store_daily_menu
      @store_daily_menu = StoreDailyMenu.find(params[:id])
    end


    def store_daily_menu_params
      params.require(:store_daily_menu).permit(:start_time,:total_num,:weather,:max_temperature,:min_temperature,
        store_daily_menu_details_attributes: [:id,:store_daily_menu_id,:product_id,:number,:row_order,:_destroy])
    end
end
