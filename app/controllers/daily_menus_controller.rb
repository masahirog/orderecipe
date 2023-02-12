class DailyMenusController < AdminController
  before_action :set_daily_menu, only: [:show, :update, :destroy]
  def store_input_disable
    @daily_menu = DailyMenu.find(params[:daily_menu_id])
    store_daily_menus = @daily_menu.store_daily_menus
    store_daily_menus.each do |sdm|
      sdm.update_column(:editable_flag,false)
    end
    redirect_to @daily_menu, :success => "店舗の発注を不可能にしました。"
  end
  def store_input_able
    @daily_menu = DailyMenu.find(params[:daily_menu_id])
    store_daily_menus = @daily_menu.store_daily_menus
    store_daily_menus.each do |sdm|
      sdm.update_column(:editable_flag,true)
    end
    redirect_to @daily_menu, :success => "店舗の発注を可能にしました。"
  end
  def cook_check
    @daily_menu = DailyMenu.find(params[:id])
    respond_to do |format|
      format.pdf do
        pdf = CookCheck.new(@daily_menu.id)
        send_data pdf.render,
        filename:    "#{@daily_menu.start_time.strftime("%m%d")}_チェックリスト.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end
  def once_change_numbers
    sozai_num_hash = {}
    bento_fukusai_num_hash = {}
    sdmds = []
    rate = params["rate"].to_f
    daily_menu = DailyMenu.find(params['daily_menu_id'])
    daily_menu.store_daily_menus.each do |sdm|
      sdm.store_daily_menu_details.each do |sdmd|
        sdmd.sozai_number = (sdmd.sozai_number * rate).ceil
        sdmd.bento_fukusai_number = (sdmd.bento_fukusai_number * rate).ceil
        sdmd.number = sdmd.sozai_number + sdmd.bento_fukusai_number
        sdmds << sdmd
        if sozai_num_hash[sdmd.product_id].present?
          sozai_num_hash[sdmd.product_id] += sdmd.sozai_number
        else
          sozai_num_hash[sdmd.product_id] = sdmd.sozai_number
        end
        if bento_fukusai_num_hash[sdmd.product_id].present?
          bento_fukusai_num_hash[sdmd.product_id] += sdmd.bento_fukusai_number
        else
          bento_fukusai_num_hash[sdmd.product_id] = sdmd.bento_fukusai_number
        end
      end
    end
    StoreDailyMenuDetail.import sdmds, on_duplicate_key_update:[:number,:sozai_number,:bento_fukusai_number]
    update_dmds = []
    total_manufacturing_number = 0
    daily_menu.daily_menu_details.each do |dmd|
      dmd.for_single_item_number = sozai_num_hash[dmd.product_id] if sozai_num_hash[dmd.product_id].present?
      dmd.for_sub_item_number = bento_fukusai_num_hash[dmd.product_id] if bento_fukusai_num_hash[dmd.product_id].present?
      if sozai_num_hash[dmd.product_id].present? && bento_fukusai_num_hash[dmd.product_id].present?
        dmd.manufacturing_number = dmd.for_single_item_number + dmd.for_sub_item_number + dmd.adjustments
        total_manufacturing_number += dmd.manufacturing_number
        update_dmds << dmd
      end
    end
    DailyMenuDetail.import update_dmds, on_duplicate_key_update:[:for_single_item_number,:for_sub_item_number,:manufacturing_number]
    daily_menu.update_attributes(total_manufacturing_number:total_manufacturing_number)

    redirect_to daily_menu, :alert => "惣菜数を#{rate*100}%掛けに変更しました"
  end
  def cut_list
    date = params[:date]
    year = date[0..3]
    month = date[5..6]
    day = date[8..9]
    date = Date.parse(date)
    @bentos_num_h = {}
    if params['beji_kuru'] == "0"
      daily_menu = DailyMenu.find(params[:daily_menu_id])
      daily_menu.daily_menu_details.each do |dmd|
        if @bentos_num_h[dmd.product_id].present?
          @bentos_num_h[dmd.product_id][0] += dmd.manufacturing_number
        else
          @bentos_num_h[dmd.product_id] = [dmd.manufacturing_number,'bejihan']
        end
      end
      @kurumesi_orders = KurumesiOrder.where(start_time:date,canceled_flag:false).order(:pick_time,:created_at)
      kurumesi_order_ids = @kurumesi_orders.ids
      @k_bentos_num_h = KurumesiOrderDetail.where(kurumesi_order_id:kurumesi_order_ids).group(:product_id).sum(:number)
      @k_bentos_num_h.each do |pn|
        if @bentos_num_h[pn[0]].present?
          @bentos_num_h[pn[0]][0] += pn[1]
        else
          @bentos_num_h[pn[0]] = [pn[1],'kurumesi']
        end
      end
    elsif params['beji_kuru'] == "1"
      daily_menu = DailyMenu.find(params[:daily_menu_id])
      daily_menu.daily_menu_details.each do |dmd|
        if @bentos_num_h[dmd.product_id].present?
          @bentos_num_h[dmd.product_id][0] += dmd.manufacturing_number
        else
          @bentos_num_h[dmd.product_id] = [dmd.manufacturing_number,'bejihan']
        end
      end
    elsif params['beji_kuru'] == "2"
      @kurumesi_orders = KurumesiOrder.where(start_time:date,canceled_flag:false).order(:pick_time,:created_at)
      kurumesi_order_ids = @kurumesi_orders.ids
      @k_bentos_num_h = KurumesiOrderDetail.where(kurumesi_order_id:kurumesi_order_ids).group(:product_id).sum(:number)
      @k_bentos_num_h.each do |pn|
        if @bentos_num_h[pn[0]].present?
          @bentos_num_h[pn[0]][0] += pn[1]
        else
          @bentos_num_h[pn[0]] = [pn[1],'kurumesi']
        end
      end
    end
    respond_to do |format|
      format.html
      format.pdf do
        pdf = CutList.new(@bentos_num_h,date,params[:list_pattern])
        send_data pdf.render,
        filename:    "#{date}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end

  def kiridasi
    products_arr = []
    menus = []
    daily_menu = DailyMenu.find(params[:id])
    date = daily_menu.start_time
    @bentos_num_h = daily_menu.daily_menu_details.group(:product_id).sum(:manufacturing_number)
    @bentos_num_h.each do |prnm|
      product = Product.find(prnm[0])
      num = prnm[1]
      products_arr << [product.name,prnm[1]]
      product.menus.each do |menu|
        menus << [menu.base_menu_id,menu.id,num]
      end
    end
    @test_hash = {}
    base_menu_hash = {}
    menus.each do |menu|
      if base_menu_hash[menu[0]]
        if base_menu_hash[menu[0]][menu[1]]
          base_menu_hash[menu[0]][menu[1]] += menu[2]
        else
          base_menu_hash[menu[0]][menu[1]] = menu[2]
        end
      else
        base_menu_hash[menu[0]] = {menu[1]=>menu[2]}
      end
    end
    @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    base_menu_hash.each do |bmh|
      bmh[1].each do |menu_num|
        menu = Menu.find(menu_num[0])
        num = menu_num[1]
        menu_materials = menu.menu_materials.includes(:material).order('materials.category').where(:materials => {measurement_flag:true})
        menu_materials.each do |mm|
          base_menu_material_id = mm.base_menu_material_id
          machine = "○" if mm.machine_flag == true
          first = "○" if mm.first_flag == true
          group = mm.source_group if mm.source_group.present?
          amount = mm.amount_used*num
          # amount = ActiveSupport::NumberHelper.number_to_rounded((mm.amount_used*num), strip_insignificant_zeros: true, :delimiter => ',')
          if mm.post == '切出/調理' || mm.post == '切出/スチ' ||mm.post == '切出し'
            if @test_hash[base_menu_material_id]
              @test_hash[base_menu_material_id][2] = @test_hash[base_menu_material_id][2] + mm.amount_used * num
              @test_hash[base_menu_material_id][6] += "、#{menu.name}（#{num}）"
            else
              @test_hash[base_menu_material_id] = ["#{mm.material.category_before_type_cast}-#{mm.material.name}",mm.material.name,amount,mm.material.recipe_unit,mm.post,mm.preparation,"#{menu.name} (#{num})",first,machine,group,mm.material_id]
            end
          end
        end
      end
    end
  end

  def cook_on_the_day
    @daily_menu = DailyMenu.find(params[:id])
    respond_to do |format|
      format.pdf do
        pdf = CookOnTheDay.new(@daily_menu.id)
        send_data pdf.render,
        filename:    "#{@daily_menu.start_time.strftime("%m%d")}_当日調理.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end
  def loading
    @daily_menu = DailyMenu.find(params[:id])
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "#{@daily_menu.start_time.strftime("%m%d")}_積載シールデータ.csv", type: :csv
      end
      format.pdf do
        pdf = DailyMenuLoadingPdf.new(@daily_menu.id)
        send_data pdf.render,
        filename:    "#{@daily_menu.start_time.strftime("%m%d")}_積載表.pdf",
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
    redirect_to daily_menus_path(), :notice => "メニューを登録しました"
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
    @total_cost = 0
    @total_sotei_uriage = 0
    @store_daily_menu_idhash = {}
    @stores = Store.all
    @date = @daily_menu.start_time
    @tommoroww = DailyMenu.find_by(start_time:@date+1)
    @yesterday = DailyMenu.find_by(start_time:@date-1)
    @daily_menu_details = @daily_menu.daily_menu_details.order("row_order ASC")
    @sdmd_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @daily_menu.store_daily_menus.includes(store_daily_menu_details:[:product]).each do |sdm|
      @store_daily_menu_idhash[sdm.store_id] = sdm.id
      sdm.store_daily_menu_details.each do |sdmd|
        @sdmd_hash[sdm.store_id][sdmd.product_id] = sdmd.number
        sell_price = sdmd.product.sell_price.to_i
        seizo_su = sdmd.sozai_number.to_i
        sotei_uriage = sell_price * seizo_su
        cost_price = sdmd.product.cost_price.to_i
        @total_cost += seizo_su * cost_price
        @total_sotei_uriage += sotei_uriage
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
        format.html { redirect_to daily_menus_path, success: "#{params['daily_menu']['start_time']}の献立を作成しました。" }
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
    @daily_menu_details = @daily_menu.products
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
    @from = params[:from]
    @to = params[:to]
    if @from.present? && @to.present?
      @daily_menus = DailyMenu.where(start_time:@from..@to)
      respond_to do |format|
        format.html
        format.pdf do
          pdf = SourcesPdf.new(@from,@to,'daily_menus')
          send_data pdf.render,
          filename:    "#{@from}_#{@to}_source.pdf",
          type:        "application/pdf",
          disposition: "inline"
        end
        format.csv do
          send_data render_to_string, filename: "#{@from}_#{@to}_source.csv", type: :csv
        end
      end
    else
      redirect_to daily_menus_path()
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
    redirect_to daily_menus_path, success: "#{count}日間、同じメニューをコピーして献立に反映しました！"
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
    redirect_to daily_menu, success: "#{count}店舗にメニュー反映しました"
  end

  private
    def set_daily_menu
      @daily_menu = DailyMenu.find(params[:id])
    end

    def daily_menu_params
      params.require(:daily_menu).permit(:start_time,:total_manufacturing_number,:sozai_manufacturing_number,
        daily_menu_details_attributes: [:id,:daily_menu_id,:product_id,:manufacturing_number,:row_order,:_destroy,
          :serving_plate_id,:signboard_flag,:window_pop_flag,:sold_outed,:for_single_item_number,:for_sub_item_number,:adjustments])
    end
end
