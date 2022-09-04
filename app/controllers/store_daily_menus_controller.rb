require "csv"
class StoreDailyMenusController < ApplicationController
  before_action :set_store_daily_menu, only: [:show, :edit, :update, :destroy]
  def barcode
    @store_daily_menu = StoreDailyMenu.find(params[:store_daily_menu_id])
    respond_to do |format|
      format.html
      format.pdf do
        pdf = Test.new(@store_daily_menu)
        send_data pdf.render,
        filename:    "#{@store_daily_menu.start_time}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end
  def description
    @store_daily_menu = StoreDailyMenu.find(params[:store_daily_menu_id])
    respond_to do |format|
      format.html
      format.pdf do
        pdf = StoreDailyMenuDescription.new(@store_daily_menu)
        send_data pdf.render,
        filename:    "#{@store_daily_menu.start_time}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end


  def input_manufacturing_number
    @store_id = params[:store_id]
    @store = Store.find(@store_id)
    @store_daily_menu_details_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @store_daily_menu_detail_ids_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    store_daily_menu_ids = params["store_daily_menu_ids"]
    @store_daily_menus = StoreDailyMenu.where(id:store_daily_menu_ids)
    store_daily_menu_details = StoreDailyMenuDetail.where(store_daily_menu_id:@store_daily_menus.ids)
    store_daily_menu_details.each do |sdmd|
      @store_daily_menu_detail_ids_hash[[sdmd.store_daily_menu_id,sdmd.product_id]]= sdmd.id
      @store_daily_menu_details_hash[[sdmd.store_daily_menu_id,sdmd.product_id]]= sdmd.sozai_number
    end
    @uniq_product_store_daily_menu_details = store_daily_menu_details.select(:product_id).distinct
    @uniq_product_ids = @uniq_product_store_daily_menu_details.map{|sdmd|sdmd.product_id}
    product_sales_potentials = ProductSalesPotential.where(store_id:@store_id,product_id:@uniq_product_ids)
    @product_sales_potentials = product_sales_potentials.map{|psp|[psp.product_id,psp.sales_potential]}.to_h
    sozai_ids = Product.where(id:@uniq_product_ids).where(bejihan_sozai_flag:true).ids
    @sozai_total_sales_potential = product_sales_potentials.where(product_id:sozai_ids).sum(:sales_potential)
    min_date = @store_daily_menus.map{|sdm|sdm.start_time}.min
    @analyses = Analysis.where(store_id:@store_id).where('date > ?',min_date-60)
    @date_sales_sozai_number = []
    @weekday_sales_sozai_number = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @analyses.map do |analysis|
      @date_sales_sozai_number << [analysis.date,analysis.total_number_sales_sozai]
      if @weekday_sales_sozai_number[analysis.date.wday].present?
        @weekday_sales_sozai_number[analysis.date.wday]['total_num'] += analysis.total_number_sales_sozai
        @weekday_sales_sozai_number[analysis.date.wday]['count'] += 1
      else
        @weekday_sales_sozai_number[analysis.date.wday]['total_num'] = analysis.total_number_sales_sozai
        @weekday_sales_sozai_number[analysis.date.wday]['count'] = 1
      end
      transaction_count = analysis.transaction_count
      analysis_products = analysis.analysis_products
      discount_sozai_number = analysis_products.joins(:product).where(:products => {bejihan_sozai_flag:true}).sum(:discount_number)
      fixed_price_sales_sozai_number = analysis.total_number_sales_sozai - discount_sozai_number
      loss_sozai_number = analysis_products.joins(:product).where(:products => {bejihan_sozai_flag:true}).where(loss_ignore:false).where('loss_number > ?', 0).sum(:loss_number)
      total_number_sales_bento =  analysis_products.joins(:product).where(:products => {product_category:5}).sum(:sales_number)
      discount_bento_number = analysis_products.joins(:product).where(:products => {product_category:5}).sum(:discount_number)
      fixed_price_sales_bento_number = total_number_sales_bento - discount_bento_number
      loss_bento_number = analysis_products.joins(:product).where(:products => {product_category:5}).where(loss_ignore:false).where('loss_number > ?', 0).sum(:loss_number)

      sdm = StoreDailyMenu.find_by(start_time:analysis.date,store_id:analysis.store_id)
      sozai_zaiko = analysis_products.joins(:product).where(:products => {bejihan_sozai_flag:true}).sum(:manufacturing_number)
      sozai_kurikoshi = analysis_products.joins(:product).where(:products => {bejihan_sozai_flag:true}).sum(:carry_over)
      bento_zaiko = analysis_products.joins(:product).where(:products => {product_category:5}).sum(:manufacturing_number)
      if sdm.present?
        weather = sdm.weather
      else
        weather = ''
      end
      @weekday_sales_sozai_number[analysis.date.wday]['rireki'][analysis.date] = [fixed_price_sales_sozai_number,weather,transaction_count,discount_sozai_number,
        loss_sozai_number,discount_bento_number,fixed_price_sales_bento_number,loss_bento_number,sozai_zaiko,sozai_kurikoshi,bento_zaiko]
    end
    @tbody_contents = {}
    @weekday_sales_sozai_number.each do |wday|
      @tbody_contents[wday[0]] = []
      wday[1]['rireki'].map do |date_num_weather|
        if date_num_weather[1][1].present?
          weather = t("enums.store_daily_menu.weather.#{date_num_weather[1][1]}")
        else
          weather = ''
        end
        @tbody_contents[wday[0]] << "<tr>
          <td>#{date_num_weather[0].strftime("%-m/%-d(#{%w(日 月 火 水 木 金 土)[date_num_weather[0].wday]})")}</td>
          <td>#{weather}</td>
          <td>#{date_num_weather[1][2]}</td>
          <td>#{date_num_weather[1][8]}</td>
          <td>#{date_num_weather[1][9]}</td>
          <td style='color:red;'>#{date_num_weather[1][0]}</td>
          <td>#{date_num_weather[1][3]}</td>
          <td>#{date_num_weather[1][4]}</td>
          <td>#{date_num_weather[1][10]}</td>
          <td style='color:red;'>#{date_num_weather[1][6]}</td>
          <td>#{date_num_weather[1][5]}</td>
          <td>#{date_num_weather[1][7]}</td>
          </tr>"
      end
      @tbody_contents[wday[0]] = @tbody_contents[wday[0]].join
    end
    @date_sales_sozai_number = @date_sales_sozai_number.to_h
  end
  def input_multi_number
    update_arr = []
    store_daily_menu_detail_ids = params[:store_daily_menu_details].keys
    store_daily_menu_details = StoreDailyMenuDetail.where(id:store_daily_menu_detail_ids)
    store_daily_menu_details_hash = store_daily_menu_details.map{|sdmd|[sdmd.id,sdmd]}.to_h
    params[:store_daily_menu_details].each do |sdmd|
      store_daily_menu_detail = store_daily_menu_details_hash[sdmd[0].to_i]
      store_daily_menu_detail.sozai_number = sdmd[1].to_i
      store_daily_menu_detail.number = store_daily_menu_detail.sozai_number + store_daily_menu_detail.bento_fukusai_number
      update_arr << store_daily_menu_detail
    end
    StoreDailyMenuDetail.import update_arr,on_duplicate_key_update:[:sozai_number,:number]
    update_dmds = []
    daily_menu_ids = store_daily_menu_details.map{|sdmd|sdmd.store_daily_menu.daily_menu_id}.uniq
    DailyMenu.where(id:daily_menu_ids).each do |daily_menu|
      sdmds = StoreDailyMenuDetail.where(store_daily_menu_id:daily_menu.store_daily_menus.ids)
      product_num_hash = sdmds.group(:product_id).sum(:number)
      sozai_num_hash = sdmds.group(:product_id).sum(:sozai_number)
      fukusai_num_hash = sdmds.group(:product_id).sum(:bento_fukusai_number)
      daily_menu.daily_menu_details.each do |dmd|
        dmd.for_single_item_number = sozai_num_hash[dmd.product_id]
        dmd.for_sub_item_number = fukusai_num_hash[dmd.product_id]
        dmd.manufacturing_number = product_num_hash[dmd.product_id]
        update_dmds << dmd
      end
    end
    DailyMenuDetail.import update_dmds, :on_duplicate_key_update => [:for_single_item_number,:manufacturing_number,:for_sub_item_number]
    redirect_to input_manufacturing_number_store_daily_menus_path(store_id:params['store_id'],store_daily_menu_ids:params['store_daily_menu_ids'].split(" ")),notice:'更新OK！'
  end
  def stock
    store_daily_menu = StoreDailyMenu.find(params[:store_daily_menu_id])
  end

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
    @store_daily_menus = @store.store_daily_menus.where(start_time:date.in_time_zone.all_month).includes(store_daily_menu_details:[:product])
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "#{date}_#{store_id}_shukei.csv", type: :csv
      end
    end
  end
  def ikkatsu
    @store_daily_menu = StoreDailyMenu.find(params[:id])
    @store_daily_menu_details = @store_daily_menu.store_daily_menu_details.includes([:serving_plate]).order("row_order ASC").includes(product:[:container,:product_ozara_serving_informations])
    @remaining_count = @store_daily_menu_details.where(initial_preparation_done:nil).count
  end

  def show
    @store_daily_menu = StoreDailyMenu.find(params[:id])
    store_id = @store_daily_menu.store_id
    date = @store_daily_menu.start_time
    @date = @store_daily_menu.start_time
    @tommoroww = StoreDailyMenu.find_by(store_id:store_id,start_time:@date+1)
    @yesterday = StoreDailyMenu.find_by(store_id:store_id,start_time:@date-1)
    @store_daily_menu_details = @store_daily_menu.store_daily_menu_details.order("row_order ASC").includes(product:[:container,:product_ozara_serving_informations])
    @after_store_daily_menus = StoreDailyMenu.where('start_time >= ?',date).where(store_id:store_id)
    pack_number = StoreDailyMenuDetail.where(store_daily_menu_id:params[:id]).joins(:product).group('products.container_id').sum(:number)
    @pack_used_amount = "<table class='table' style='text-align:left;'><thead><tr><th>容器名</th><th>個数</th></tr></thead><tbody>"
    pack_number.each do |pn|
      if pn[0].present?
        name = Container.find(pn[0]).name
        number = pn[1]
      else
        name = '不明'
        number = pn[1]
      end
      @pack_used_amount += "<tr><td>#{name}</td><td>#{number}</td></tr>"
    end
    @pack_used_amount += "</tbody></table>"
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

  def edit
    daily_menu = @store_daily_menu.daily_menu
    default_product_ids = [11429,13059]
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

  def upload_number
    @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    store_id = params[:store_id]
    @store = Store.find(params[:store_id])
    file = params[:file]
    dates = []
    CSV.foreach(file.path,liberal_parsing:true, headers: true) do |row|
      date = Date.parse(row["date"])
      dates <<  row["date"]
      product_id = row["product_id"].to_i
      number = row[store_id].to_i
      showcase_type = row['showcase_type'].to_i
      serving_plate_id = row['serving_plate_id']
      @hash[date][product_id]['after_number'] = number
      @hash[date][product_id]['showcase_type'] = showcase_type
      @hash[date][product_id]['serving_plate_id'] = serving_plate_id
    end

    dates = dates.uniq
    @store_daily_menu_details = StoreDailyMenuDetail.includes(:store_daily_menu,:product).joins(:store_daily_menu).where(:store_daily_menus => {start_time:dates,store_id:store_id})
    @store_daily_menu_details.each do |sdmd|
      @hash[sdmd.store_daily_menu.start_time][sdmd.product_id]['before_number'] = sdmd.bento_fukusai_number
      @hash[sdmd.store_daily_menu.start_time][sdmd.product_id]['product_name'] = sdmd.product.name
      @hash[sdmd.store_daily_menu.start_time][sdmd.product_id]['sdmd_id'] = sdmd.id
    end
    render :upload_number
  end
  def once_update_number
    sdmds_arr = []
    daily_menu_ids = []
    update_dmds = []
    store_daily_menu_ids = []
    store_id = params[:store_id]
    @store = Store.find(params[:store_id])
    params["update_sdmds"].each do |update_sdmd|
      sdmd_id = update_sdmd[0]
      num = update_sdmd[1]["after_number"].to_i
      showcase_type = update_sdmd[1]["showcase_type"].to_i
      serving_plate_id = update_sdmd[1]["serving_plate_id"]
      sdmd = StoreDailyMenuDetail.find(sdmd_id)
      daily_menu_ids << sdmd.store_daily_menu.daily_menu_id
      store_daily_menu_ids << sdmd.store_daily_menu_id
      if params['bento_fukusai_number_update_flag'].present?
        sdmd.bento_fukusai_number = num
        sdmd.number = num + sdmd.sozai_number
      end
      sdmd.showcase_type = showcase_type if params['showcase_type_update_flag'].present?
      sdmd.serving_plate_id = serving_plate_id if params['serving_plate_update_flag'].present?
      sdmds_arr << sdmd
    end
    StoreDailyMenuDetail.import sdmds_arr, :on_duplicate_key_update => [:bento_fukusai_number,:number,:showcase_type,:serving_plate_id]
    daily_menu_ids = daily_menu_ids.uniq
    DailyMenu.where(id:daily_menu_ids).each do |daily_menu|
      sdmds = StoreDailyMenuDetail.where(store_daily_menu_id:daily_menu.store_daily_menus.ids)
      product_num_hash = sdmds.group(:product_id).sum(:number)
      sozai_num_hash = sdmds.group(:product_id).sum(:sozai_number)
      fukusai_num_hash = sdmds.group(:product_id).sum(:bento_fukusai_number)
      daily_menu.daily_menu_details.each do |dmd|
        dmd.for_single_item_number = sozai_num_hash[dmd.product_id]
        dmd.for_sub_item_number = fukusai_num_hash[dmd.product_id]
        dmd.manufacturing_number = product_num_hash[dmd.product_id]
        update_dmds << dmd
      end
    end
    DailyMenuDetail.import update_dmds, :on_duplicate_key_update => [:for_single_item_number,:manufacturing_number,:for_sub_item_number]
    redirect_to store_daily_menus_path(store_id:store_id)
  end


  private

    def set_store_daily_menu
      @store_daily_menu = StoreDailyMenu.find(params[:id])
    end


    def store_daily_menu_params
      params.require(:store_daily_menu).permit(:start_time,:total_num,:weather,:max_temperature,:min_temperature,:opentime_showcase_photo,
        :showcase_photo_a,:showcase_photo_b,:signboard_photo,:opentime_showcase_photo_uploaded,
        store_daily_menu_photos_attributes: [:id,:store_daily_menu_id,:image],
        store_daily_menu_details_attributes: [:id,:store_daily_menu_id,:product_id,:number,:row_order,:_destroy,
          :actual_inventory,:carry_over,:sold_out_flag,:serving_plate_id,:signboard_flag,
          :window_pop_flag,:stock_deficiency_excess,:sozai_number,:bento_fukusai_number])
    end
end
