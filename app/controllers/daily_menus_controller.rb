class DailyMenusController < AdminController
  before_action :set_daily_menu, only: [:show, :update, :destroy]
  def loading
    @daily_menu = DailyMenu.find(params[:id])
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "#{@daily_menu.id}_loading.csv", type: :csv
      end
      format.pdf do
        pdf = DailyMenuLoadingPdf.new(@daily_menu.id)
        send_data pdf.render,
        filename:    "#{@daily_menu.id}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end
  def create_1month
    date = params[:date]
    DailyMenu.once_1month_create(date)
    redirect_to daily_menus_path
  end
  def upload_menu
    update_result = DailyMenu.upload_menu(params[:file])
    if update_result = 0
      redirect_to daily_menus_path(), :alert => 'csvデータが正しいかどうか確認してください'
    else
      redirect_to daily_menus_path(), :notice => "メニューを登録しました"
    end
  end
  def index
    today = Date.today
    if params[:start_date].present?
      @date = params[:start_date]
    else
      @date = today
    end
    @daily_menus = DailyMenu.where(start_time:@date.in_time_zone.all_month).includes(daily_menu_details:[:product])
    @today_after_daily_menus = @daily_menus.where('start_time >= ?',today).order('start_time')
    @stores = Store.all
  end

  def show
    @store_daily_menu_idhash = {}
    @stores = Store.all
    @date = @daily_menu.start_time
    @tommoroww = DailyMenu.find_by(start_time:@date+1)
    @yesterday = DailyMenu.find_by(start_time:@date-1)
    @daily_menu_details = @daily_menu.daily_menu_details.order("row_order ASC").includes(:product)
    @sdmd_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @daily_menu.store_daily_menus.includes(:store_daily_menu_details).each do |sdm|
      @store_daily_menu_idhash[sdm.store_id] = sdm.id
      sdm.store_daily_menu_details.each do |sdmd|
        @sdmd_hash[sdm.store_id][sdmd.product_id] = sdmd.number
      end
    end
    respond_to do |format|
      format.html
      format.pdf do
        pdf = DailyMenuPdf.new(@daily_menu.id)
        send_data pdf.render,
        filename:    "#{@daily_menu.id}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end

  def new
    @store_daily_menus = Hash.new { |h,k| h[k] = {} }
    @products = Product.where(brand_id:111)
    date = params['start_time']
    @date = Date.parse(date)
    @tommoroww = DailyMenu.find_by(start_time:@date+1)
    @yesterday = DailyMenu.find_by(start_time:@date-1)
    if DailyMenu.where(start_time:date).present?
      id = DailyMenu.find_by(start_time:date).id
      redirect_to "/daily_menus/#{id}/edit"
    else
      @daily_menu = DailyMenu.new
      @daily_menu_details = []
      @hash = {}
    end
  end

  def edit
    @daily_menu = DailyMenu.includes(daily_menu_details:[:product]).find(params[:id])
    store_daily_menus = @daily_menu.store_daily_menus.includes(:store_daily_menu_details)
    @store_daily_menus = Hash.new { |h,k| h[k] = {} }
    store_daily_menus.each do |sdm|
      sdm.store_daily_menu_details.each do |sdmd|
        @store_daily_menus[sdm.store_id][sdmd.product_id] = {number:sdmd.number}
      end
    end
    @date = @daily_menu.start_time
    @tommoroww = DailyMenu.find_by(start_time:@date+1)
    @yesterday = DailyMenu.find_by(start_time:@date-1)
    @products = Product.where(brand_id:111)
    @daily_menu_details = @daily_menu.products
  end

  def create
    @products = Product.where(brand_id:111)
    @daily_menu = DailyMenu.new(daily_menu_params)
    respond_to do |format|
      if @daily_menu.save
        format.html { redirect_to daily_menus_path, notice: "#{params['daily_menu']['start_time']}の献立を作成しました。" }
        format.json { render :show, status: :created, location: @daily_menu }
      else
        format.html { render :new }
        format.json { render json: @daily_menu.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    store_daily_menus = @daily_menu.store_daily_menus.includes(:store_daily_menu_details)
    @store_daily_menus = Hash.new { |h,k| h[k] = {} }
    store_daily_menus.each do |sdm|
      sdm.store_daily_menu_details.each do |sdmd|
        @store_daily_menus[sdm.store_id][sdmd.product_id] = {number:sdmd.number}
      end
    end

    @date = @daily_menu.start_time
    @tommoroww = DailyMenu.find_by(start_time:@date+1)
    @yesterday = DailyMenu.find_by(start_time:@date-1)
    @place_showcases = PlaceShowcase.all
    @daily_menu_details = @daily_menu.products
    @hash = @daily_menu.daily_menu_details.map do |dmd|
      [dmd.place_showcase_id,dmd.product_id] if dmd.place_showcase_id.present?
    end
    @hash = @hash.compact.to_h

    @products = Product.where(brand_id:111)
    respond_to do |format|
      if @daily_menu.update(daily_menu_params)
        format.html { redirect_to @daily_menu, notice: 'Daily menu was successfully updated.' }
        format.json { render :show, status: :ok, location: @daily_menu }
      else
        format.html { render :edit }
        format.json { render json: @daily_menu.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @daily_menu.destroy
    respond_to do |format|
      format.html { redirect_to daily_menus_url, notice: 'Daily menu was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def products_pdfs
    daily_menu = DailyMenu.includes(daily_menu_details:[product:[menus:[:materials]]]).find(params[:daily_menu_id])
    respond_to do |format|
      format.html
      format.pdf do
        pdf = ProductPdfAll.new(daily_menu.id,'daily_menus')
        send_data pdf.render,
        filename:    "#{daily_menu.id}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end

  def sources
    @daily_menu = DailyMenu.includes(daily_menu_details:[product:[menus:[:materials]]]).find(params[:daily_menu_id])
    respond_to do |format|
      format.html
      format.pdf do
        pdf = SourcesPdf.new(@daily_menu.start_time,'daily_menus')
        send_data pdf.render,
        filename:    "#{@daily_menu.id}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
      format.csv do
        send_data render_to_string, filename: "#{@daily_menu.id}_source.csv", type: :csv
      end
    end
  end

  # def recipes_roma
  #   daily_menu = DailyMenu.includes(daily_menu_details:[product:[menus:[:materials]]]).find(params[:daily_menu_id])
  #   respond_to do |format|
  #     format.html
  #     format.pdf do
  #       pdf = ProductPdfAllRoma.new(daily_menu.id,'daily_menus')
  #       send_data pdf.render,
  #       filename:    "#{daily_menu.id}.pdf",
  #       type:        "application/pdf",
  #       disposition: "inline"
  #     end
  #   end
  # end
  # def print_preparation
  #   mochiba = params[:mochiba]
  #   daily_menu = DailyMenu.includes(daily_menu_details:[product:[menus:[:materials]]]).find(params[:daily_menu_id])
  #   respond_to do |format|
  #     format.html
  #     format.pdf do
  #       pdf = ShogunPreparationAll.new(daily_menu,mochiba)
  #       send_data pdf.render,
  #       filename:    "#{daily_menu.id}.pdf",
  #       type:        "application/pdf",
  #       disposition: "inline"
  #     end
  #   end
  # end
  def material_preparation
    category = params[:category]
    mochiba = params[:mochiba]
    lang = params[:lang]
    daily_menu = DailyMenu.find(params[:daily_menu_id])
    date = daily_menu.start_time
    sort = params[:sort].to_i
    @bentos_num_h = daily_menu.daily_menu_details.group(:product_id).sum(:manufacturing_number)
    respond_to do |format|
      format.html
      format.pdf do
        pdf = MaterialPreparation.new(@bentos_num_h,date,mochiba,lang,sort,category)
        send_data pdf.render,
        filename:    "#{date}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end

  def copy
    copied_menu_id = params[:daily_menu_id]
    copied_daily_menu = DailyMenu.find(copied_menu_id)
    dates = params[:dates].compact.reject(&:empty?)
    if dates.empty?
      count = 0
    else
      count = 0
      dates.each do |date|
        daily_menu = DailyMenu.find_by(start_time:date)
        if daily_menu.present?
        else
          copy_daily_menu = copied_daily_menu.deep_clone(include: [:daily_menu_details])
          copy_daily_menu.start_time = date
          copy_daily_menu.save
          count += 1
        end
      end
    end
    redirect_to daily_menus_path, notice: "#{count}日間、同じメニューをコピーして献立に反映しました！"
  end

  def once_store_reflect
    store_daily_menu_details_arr = []
    params['daily_menu_store'].each do |dms|
      if dms[1]['reflect_flag'].present?
        store_ids = dms[1]['reflect_flag'].keys
        start_time = dms[1]['start_time']
        daily_menu_id = dms[0]
        daily_menu = DailyMenu.find(daily_menu_id)
        store_ids.each do |store_id|
          store_daily_menu = StoreDailyMenu.find_by(daily_menu_id:daily_menu_id,store_id:store_id)
          if store_daily_menu.present?
          else
            store_daily_menu = StoreDailyMenu.create(daily_menu_id:daily_menu_id,store_id:store_id,start_time:start_time)
          end
          if store_daily_menu.store_daily_menu_details.present?
            sdmd_product_ids = store_daily_menu.store_daily_menu_details.map{|sdmd|sdmd.product_id}
            dmd_product_ids = daily_menu.daily_menu_details.map{|dmd|dmd.product_id}
            add_product_ids = dmd_product_ids - sdmd_product_ids
            dmds = daily_menu.daily_menu_details.where(product_id:add_product_ids)
          else
            dmds = daily_menu.daily_menu_details
          end
          dmds.each do |dmd|
            store_daily_menu_details_arr << StoreDailyMenuDetail.new(store_daily_menu_id:store_daily_menu.id,product_id:dmd.product_id,row_order:dmd.row_order)
          end
        end
      end
    end
    StoreDailyMenuDetail.import store_daily_menu_details_arr
    redirect_to daily_menus_path
  end

  def store_reflect
    store_daily_menu_details_arr = []
    daily_menu_id = params[:daily_menu_id]
    daily_menu = DailyMenu.find(daily_menu_id)
    start_time = daily_menu.start_time
    count = 0
    params['stores'].each do |store|
      store_id = store[1]['id']
      reflect_flag = store[1]['reflect']
      if reflect_flag == "true"
        store_daily_menu = StoreDailyMenu.create(daily_menu_id:daily_menu_id,store_id:store_id,start_time:start_time)
        daily_menu.daily_menu_details.each do |dmd|
          store_daily_menu_details_arr << StoreDailyMenuDetail.new(store_daily_menu_id:store_daily_menu.id,product_id:dmd.product_id,row_order:dmd.row_order)
        end
        count += 1
      end
    end
    StoreDailyMenuDetail.import store_daily_menu_details_arr
    redirect_to daily_menu, notice: "#{count}店舗にメニュー反映しました"
  end

  private
    def set_daily_menu
      @daily_menu = DailyMenu.find(params[:id])
    end

    def daily_menu_params
      params.require(:daily_menu).permit(:start_time,:total_manufacturing_number,:sozai_manufacturing_number,:weather,:max_temperature,:min_temperature,daily_menu_photos_attributes: [:id,:daily_menu_id,:image],
        daily_menu_details_attributes: [:id,:daily_menu_id,:product_id,:manufacturing_number,:row_order,:_destroy,
          :serving_plate_id,:place_showcase_id,:signboard_flag,:window_pop_flag,:sold_outed,:for_single_item_number,:for_sub_item_number])
    end
end
