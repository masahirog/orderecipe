require "csv"
class StoreDailyMenusController < AdminController
  before_action :set_store_daily_menu, only: [:show, :edit, :update, :destroy]

  def ou_menu_update
    @store_daily_menu = StoreDailyMenu.find(params[:store_daily_menu_id])
    @store_daily_menu_details = @store_daily_menu.store_daily_menu_details
    @hash = {}
    @store_daily_menu_details.each do |sdmd|
      product = sdmd.product
      store_daily_menu_ids = StoreDailyMenu.where(store_id:@store_daily_menu.store_id).where("id < ?",@store_daily_menu.id)
      @hash[sdmd.product_id] = product.store_daily_menu_details.where(store_daily_menu_id:store_daily_menu_ids).count
    end
  end

  def bento_label
    @store_daily_menu = StoreDailyMenu.find(params[:id])
    date = @store_daily_menu.start_time
    store_name = @store_daily_menu.store.name
    @labels = []
    bento_ids = []
    number_product = @store_daily_menu.daily_menu.daily_menu_details.map{|dmd|[dmd.paper_menu_number,dmd.product_id]}.to_h
    number_product.each do |data|
      @soup = Product.find(data[1]) if data[0] == 1
      bento_ids << data[1] if [24,25,26,27].include?(data[0])
      @fukusai1 = Product.find(data[1]) if data[0] == 2
      @fukusai2 = Product.find(data[1]) if data[0] == 3
      @fukusai3 = params[:daily_fukusai]
    end
    @sdmds = @store_daily_menu.store_daily_menu_details.where(product_id:bento_ids)
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "#{store_name}_#{date}_bento_.csv", type: :csv
      end
    end
  end

  def label
    @store_daily_menu = StoreDailyMenu.find(params[:store_daily_menu_id])
    date = @store_daily_menu.start_time
    store_name = @store_daily_menu.store.name
    normal_labels = []
    inversion_labels = []
    @store_daily_menu.store_daily_menu_details.each do |sdmd|
      if sdmd.product.container_id.present?
        if sdmd.product.container.inversion_label_flag == true
          inversion_labels << sdmd
        else
          normal_labels << sdmd
        end
      else
        normal_labels << sdmd
      end
    end
    if params[:pattern] == "inversion"
      pattern = "反転"
      @store_daily_menu_details = inversion_labels
    else
      pattern = "正面"
      @store_daily_menu_details = normal_labels
    end
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "#{store_name}_#{date}_#{pattern}_.csv", type: :csv
      end
    end
  end

  def budget_update
    @store_daily_menu = StoreDailyMenu.find(params[:store_daily_menu_id])
    if params[:foods_budget].present?
      @store_daily_menu.update_column(:foods_budget,params[:foods_budget])
    else
      @store_daily_menu.update_column(:goods_budget,params[:goods_budget])
    end
    @budget = @store_daily_menu.foods_budget.to_i + @store_daily_menu.goods_budget.to_i
    date = @store_daily_menu.start_time
    store_id = @store_daily_menu.store_id
    dates = (date.beginning_of_month..date.end_of_month).to_a
    @store_daily_menus = StoreDailyMenu.where(start_time:dates,store_id:store_id)
    @foods_total_budget = 0
    @goods_total_budget = 0
    @store_daily_menus.each do |sdm|
      @foods_total_budget += sdm.foods_budget.to_i
      @goods_total_budget += sdm.goods_budget.to_i
    end
    @total_budget = @foods_total_budget + @goods_total_budget
    respond_to do |format|
      format.js
      format.html
    end
  end

  def budget
    if params[:date]
      @date = Date.parse(params[:date])
    else
      @date = Date.today
    end
    @store = Store.find(params[:store_id])
    @dates = (@date.beginning_of_month..@date.end_of_month).to_a
    @store_daily_menus = StoreDailyMenu.where(start_time:@dates,store_id:params[:store_id])
    @foods_total_budget = 0
    @goods_total_budget = 0
    @store_daily_menus.each do |sdm|
      @foods_total_budget += sdm.foods_budget.to_i
      @goods_total_budget += sdm.goods_budget.to_i
    end
    @total_budget = @foods_total_budget+@goods_total_budget
  end

  def input_manufacturing_number
    @store_id = params[:store_id]
    @store = Store.find(@store_id)
    @store_daily_menu_details_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @store_daily_menu_detail_ids_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @store_daily_menu_details_bento_fukusai_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    store_daily_menu_ids = params["store_daily_menu_ids"]
    @store_daily_menus = StoreDailyMenu.where(id:store_daily_menu_ids).order(:start_time)
    store_daily_menu_details = StoreDailyMenuDetail.where(store_daily_menu_id:@store_daily_menus.ids)
    store_daily_menu_details.each do |sdmd|
      @store_daily_menu_detail_ids_hash[[sdmd.store_daily_menu_id,sdmd.product_id]]= sdmd.id
      @store_daily_menu_details_hash[[sdmd.store_daily_menu_id,sdmd.product_id]]= sdmd.sozai_number
      @store_daily_menu_details_bento_fukusai_hash[[sdmd.store_daily_menu_id,sdmd.product_id]]= sdmd.bento_fukusai_number
    end
    product_ids = store_daily_menu_details.map{|sdmd|sdmd.product_id}.uniq
    # @products = Product.where(id: product_ids).order(['field(id, ?)', product_ids])
    @products = Product.where(id: product_ids).order(:product_category)
    product_sales_potentials = ProductSalesPotential.where(store_id:@store_id,product_id:product_ids)
    @product_sales_potentials = product_sales_potentials.map{|psp|[psp.product_id,psp.sales_potential]}.to_h
    sozai_ids = Product.where(id:product_ids).where(bejihan_sozai_flag:true).ids
    @sozai_total_sales_potential = product_sales_potentials.where(product_id:sozai_ids).sum(:sales_potential)
    min_date = @store_daily_menus.map{|sdm|sdm.start_time}.min
    @analyses = Analysis.includes(:store_daily_menu).where(store_id:@store_id).where('date > ?',min_date-60)
    @date_sales_sozai_number = @analyses.map{|analysis|[analysis.date,analysis.total_sozai_sales_number]}.to_h
    @weekday_sales_sozai_number = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    date_weather = StoreDailyMenu.where('start_time > ?',min_date-60).where(store_id:@store_id).map{|sdm|[sdm.start_time,sdm.weather]}.to_h
    analysis_products_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    sozai_analysis_products = AnalysisProduct.joins(:product).where(:products => {bejihan_sozai_flag:true}).where(analysis_id:@analyses.ids)
    sozai_analysis_products.each do |ap|
      if analysis_products_hash[ap.analysis_id][:sozai].present?
        analysis_products_hash[ap.analysis_id][:sozai][:discount_number] += ap.discount_number
        analysis_products_hash[ap.analysis_id][:sozai][:loss_number] += ap.loss_number.to_i if ap.loss_ignore == false
        analysis_products_hash[ap.analysis_id][:sozai][:manufacturing_number] += ap.manufacturing_number.to_i
        analysis_products_hash[ap.analysis_id][:sozai][:carry_over] += ap.carry_over.to_i
      else
        analysis_products_hash[ap.analysis_id][:sozai][:discount_number] = ap.discount_number
        if ap.loss_ignore == false
          analysis_products_hash[ap.analysis_id][:sozai][:loss_number] = ap.loss_number.to_i
        else
          analysis_products_hash[ap.analysis_id][:sozai][:loss_number] = 0
        end
        analysis_products_hash[ap.analysis_id][:sozai][:manufacturing_number] = ap.manufacturing_number.to_i
        analysis_products_hash[ap.analysis_id][:sozai][:carry_over] = ap.carry_over.to_i
      end
    end
    bento_analysis_products = AnalysisProduct.joins(:product).where(:products => {product_category:5}).where(analysis_id:@analyses.ids)
    bento_analysis_products.each do |ap|
      if analysis_products_hash[ap.analysis_id][:bento].present?
        analysis_products_hash[ap.analysis_id][:bento][:discount_number] += ap.discount_number.to_i
        analysis_products_hash[ap.analysis_id][:bento][:loss_number] += ap.loss_number.to_i if ap.loss_ignore == false
        analysis_products_hash[ap.analysis_id][:bento][:manufacturing_number] += ap.manufacturing_number.to_i
        analysis_products_hash[ap.analysis_id][:bento][:sales_number] += ap.sales_number.to_i
      else
        analysis_products_hash[ap.analysis_id][:bento][:discount_number] = ap.discount_number.to_i
        if ap.loss_ignore == false
          analysis_products_hash[ap.analysis_id][:bento][:loss_number] = ap.loss_number.to_i
        else
          analysis_products_hash[ap.analysis_id][:bento][:loss_number] = 0
        end
        analysis_products_hash[ap.analysis_id][:bento][:manufacturing_number] = ap.manufacturing_number.to_i
        analysis_products_hash[ap.analysis_id][:bento][:sales_number] = ap.sales_number.to_i
      end
    end

    AnalysisProduct.joins(:product).where(:products => {product_category:3}).where(analysis_id:@analyses.ids).each do |ap|
       analysis_products_hash[ap.analysis_id][:sweets][:sales_number] = ap.sales_number.to_i
       analysis_products_hash[ap.analysis_id][:sweets][:manufacturing_number] = ap.manufacturing_number.to_i
    end
    AnalysisProduct.joins(:product).where(:products => {product_category:7}).where(analysis_id:@analyses.ids).each do |ap|
       analysis_products_hash[ap.analysis_id][:soup][:sales_number] = ap.sales_number.to_i
       analysis_products_hash[ap.analysis_id][:soup][:manufacturing_number] = ap.manufacturing_number.to_i
    end


    @analyses.map do |analysis|
      discount_sozai_number = analysis_products_hash[analysis.id][:sozai][:discount_number]
      loss_sozai_number = analysis_products_hash[analysis.id][:sozai][:loss_number]
      sozai_zaiko = analysis_products_hash[analysis.id][:sozai][:manufacturing_number]
      sozai_kurikoshi = analysis_products_hash[analysis.id][:sozai][:carry_over]

      total_number_sales_bento = analysis_products_hash[analysis.id][:bento][:sales_number]
      discount_bento_number = analysis_products_hash[analysis.id][:bento][:discount_number]
      loss_bento_number = analysis_products_hash[analysis.id][:bento][:loss_number]
      bento_zaiko = analysis_products_hash[analysis.id][:bento][:manufacturing_number]
      soup = "#{analysis_products_hash[analysis.id][:soup][:sales_number]}（#{analysis_products_hash[analysis.id][:soup][:manufacturing_number]}）"
      sweets = "#{analysis_products_hash[analysis.id][:sweets][:sales_number]}（#{analysis_products_hash[analysis.id][:sweets][:manufacturing_number]}）"

      if @weekday_sales_sozai_number[analysis.store_daily_menu.start_time.wday].present?
        @weekday_sales_sozai_number[analysis.store_daily_menu.start_time.wday]['total_num'] += analysis.total_sozai_sales_number
        @weekday_sales_sozai_number[analysis.store_daily_menu.start_time.wday]['count'] += 1
      else
        @weekday_sales_sozai_number[analysis.store_daily_menu.start_time.wday]['total_num'] = analysis.total_sozai_sales_number
        @weekday_sales_sozai_number[analysis.store_daily_menu.start_time.wday]['count'] = 1
      end
      transaction_count = analysis.transaction_count
      if discount_sozai_number.present?
        fixed_price_sales_sozai_number = analysis.total_sozai_sales_number - discount_sozai_number
      else
        fixed_price_sales_sozai_number = ''
      end
      if total_number_sales_bento.present?
        fixed_price_sales_bento_number = total_number_sales_bento - discount_bento_number
      else
        fixed_price_sales_bento_number = ''
      end
      if date_weather[analysis.date].present?
        weather = date_weather[analysis.date]
      else
        weather = ''
      end
      @weekday_sales_sozai_number[analysis.store_daily_menu.start_time.wday]['rireki'][analysis.store_daily_menu.start_time] = [fixed_price_sales_sozai_number,weather,transaction_count,discount_sozai_number,
        loss_sozai_number,discount_bento_number,fixed_price_sales_bento_number,loss_bento_number,sozai_zaiko,sozai_kurikoshi,bento_zaiko,soup,sweets]
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
          <td style='border-left: 1px solid #d3d3d3;'>#{date_num_weather[1][8]}</td>
          <td>#{date_num_weather[1][9]}</td>
          <td style='color:red;'>#{date_num_weather[1][0]}</td>
          <td>#{date_num_weather[1][3]}</td>
          <td>#{date_num_weather[1][4]}</td>
          <td style='border-left: 1px solid #d3d3d3;'>#{date_num_weather[1][10]}</td>
          <td style='color:red;'>#{date_num_weather[1][6]}</td>
          <td>#{date_num_weather[1][5]}</td>
          <td>#{date_num_weather[1][7]}</td>
          <td style='border-left: 1px solid #d3d3d3;'>#{date_num_weather[1][11]}</td>
          <td style='border-left: 1px solid #d3d3d3;'>#{date_num_weather[1][12]}</td>
          </tr>"
      end
      @tbody_contents[wday[0]] = @tbody_contents[wday[0]].join
    end
  end
  def input_multi_number
    update_arr = []
    store_daily_menu_detail_ids = params[:store_daily_menu_details].keys
    store_daily_menu_details = StoreDailyMenuDetail.where(id:store_daily_menu_detail_ids)
    store_daily_menu_details_hash = store_daily_menu_details.map{|sdmd|[sdmd.id,sdmd]}.to_h
    params[:store_daily_menu_details].each do |sdmd|
      store_daily_menu_detail = store_daily_menu_details_hash[sdmd[0].to_i]
      store_daily_menu_detail.sozai_number = sdmd[1]['sozai_number'].to_i
      store_daily_menu_detail.bento_fukusai_number = sdmd[1]['fukusai_number'].to_i if sdmd[1]['fukusai_number'].present?
      store_daily_menu_detail.number = store_daily_menu_detail.sozai_number + store_daily_menu_detail.bento_fukusai_number
      update_arr << store_daily_menu_detail
    end
    StoreDailyMenuDetail.import update_arr,on_duplicate_key_update:[:sozai_number,:number,:bento_fukusai_number]
    update_dmds = []
    update_dms = []
    daily_menu_ids = store_daily_menu_details.map{|sdmd|sdmd.store_daily_menu.daily_menu_id}.uniq
    DailyMenu.where(id:daily_menu_ids).each do |daily_menu|
      daily_menu.stock_update_flag = true
      update_dms << daily_menu
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
    DailyMenu.import update_dms, :on_duplicate_key_update => [:stock_update_flag]
    DailyMenuDetail.import update_dmds, :on_duplicate_key_update => [:for_single_item_number,:manufacturing_number,:for_sub_item_number]
    redirect_to input_manufacturing_number_store_daily_menus_path(store_id:params['store_id'],store_daily_menu_ids:params['store_daily_menu_ids'].split(" ")),notice:'更新OK！'
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
    product_ids = StoreDailyMenuDetail.where(store_daily_menu_id:@store_daily_menus.ids).map{|sdmd|sdmd.product_id}.uniq
    @last_process = {}
    Product.where(id:product_ids).each do |product|
      last_processes = MenuLastProcess.where(menu_id:product.menus.ids)
      if last_processes.present?
        @last_process[product.id] = "◯"
      else
        @last_process[product.id] = ""
      end
    end
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "#{date}_#{store_id}_shukei.csv", type: :csv
      end
    end
  end
  def ikkatsu
    @serving_plates = ServingPlate.all.map{|serving_plate|[serving_plate.id,serving_plate]}.to_h
    @store_daily_menu = StoreDailyMenu.find(params[:id])
    @date = @store_daily_menu.start_time
    @to_store_messages = ToStoreMessage.joins(:to_store_message_stores).where(:to_store_message_stores => {store_id:@store_daily_menu.store_id}).where(date:@date)
    @store_daily_menu_details = @store_daily_menu.store_daily_menu_details.includes(:serving_plate,:store_daily_menu_detail_histories).order("row_order ASC").includes(product:[:container,:product_ozara_serving_informations,:product_pack_serving_informations])
    @remaining_count = @store_daily_menu_details.where(prepared_number:0).count
    respond_to do |format|
      format.js
      format.html
    end
  end

  def show
    @serving_plates = ServingPlate.all.map{|serving_plate|[serving_plate.id,serving_plate]}.to_h
    @store_daily_menu = StoreDailyMenu.find(params[:id])
    store_id = @store_daily_menu.store_id
    @date = @store_daily_menu.start_time
    @to_store_messages = ToStoreMessage.joins(:to_store_message_stores).where(:to_store_message_stores => {store_id:@store_daily_menu.store_id,subject_flag:true}).where(date:@date)
    @tommoroww = StoreDailyMenu.find_by(store_id:store_id,start_time:@date+1)
    @yesterday = StoreDailyMenu.find_by(store_id:store_id,start_time:@date-1)
    @store_daily_menu_details = @store_daily_menu.store_daily_menu_details.order("row_order ASC").includes(product:[:container,:product_ozara_serving_informations,:product_pack_serving_informations])
    @after_store_daily_menus = StoreDailyMenu.where('start_time >= ?',@date).where(store_id:store_id).order(:start_time)
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
      photo_a_was = @store_daily_menu.showcase_photo_a.url
      photo_b_was = @store_daily_menu.showcase_photo_b.url
      if @store_daily_menu.update(store_daily_menu_params)
        photo_a = @store_daily_menu.showcase_photo_a.url
        photo_b = @store_daily_menu.showcase_photo_b.url
        if photo_a_was == photo_a && photo_b_was == photo_b
        else
          shift = Shift.find_by(store_id:@store_daily_menu.store_id,date:@store_daily_menu.start_time,fix_shift_pattern_id:254)
          if shift.present?
            staff_name = shift.staff.name
          else
            staff_name = ""
          end

          message = "ショーケースの写真を更新しました！\n"+
          "店舗名：#{@store_daily_menu.store.short_name}\n"+
          "日付：#{@store_daily_menu.start_time.strftime("%-m/%-d(#{%w(日 月 火 水 木 金 土)[@store_daily_menu.start_time.wday]})")}\n"+
          "販売社員：#{staff_name}"
          attachment_images =[]
          attachment_images << {image_url: photo_a} if photo_a.present?
          attachment_images << {image_url: photo_b} if photo_b.present?
          Slack::Notifier.new("https://hooks.slack.com/services/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", username: 'Bot', icon_emoji: ':male-farmer:', attachments: attachment_images).ping(message)
          # Slack::Notifier.new("https://hooks.slack.com/services/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", username: 'Bot', icon_emoji: ':male-farmer:', attachments: attachment_images).ping(message)
        end
        format.js
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
    redirect_to store_daily_menus_path(store_id:store_id), success: "まとめて更新しました"
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
      row_order = row["row_order"].to_i
      number = row[store_id].to_i
      showcase_type = row['showcase_type'].to_i
      serving_plate_id = row['serving_plate_id']
      @hash[date][product_id]['after_number'] = number
      @hash[date][product_id]['showcase_type'] = showcase_type
      @hash[date][product_id]['serving_plate_id'] = serving_plate_id
      @hash[date][product_id]['row_order'] = row_order
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
      row_order = update_sdmd[1]["row_order"]
      sdmd = StoreDailyMenuDetail.find(sdmd_id)
      daily_menu_ids << sdmd.store_daily_menu.daily_menu_id
      store_daily_menu_ids << sdmd.store_daily_menu_id
      if params['bento_fukusai_number_update_flag'].present?
        sdmd.bento_fukusai_number = num
        sdmd.number = num + sdmd.sozai_number
      end
      sdmd.showcase_type = showcase_type if params['showcase_type_update_flag'].present?
      sdmd.serving_plate_id = serving_plate_id if params['serving_plate_update_flag'].present?
      sdmd.row_order = row_order if params['row_order_update_flag'].present?
      sdmds_arr << sdmd
    end
    StoreDailyMenuDetail.import sdmds_arr, :on_duplicate_key_update => [:bento_fukusai_number,:number,:showcase_type,:serving_plate_id,:row_order]
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

  def new
    date = Date.parse(params[:date])
    store_id = params[:store_id]
    @store = Store.find(store_id)
    daily_menu = DailyMenu.find_by(start_time:date)
    default_product_ids = [13059]
    dmd_product_ids = default_product_ids
    @dmd_products = Product.where(id:dmd_product_ids)

    # @tommoroww = DailyMenu.find_by(start_time:date+1)
    # @yesterday = DailyMenu.find_by(start_time:date-1)
    @products = Product.where(brand_id:111)
    # @store_daily_menu_details = @store_daily_menu.products


    if daily_menu.present?
      @store_daily_menu = StoreDailyMenu.new(start_time:date,store_id:store_id,daily_menu_id:daily_menu.id)
      saveble_photo_nums = 3
      saveble_photo_nums.times {
        @store_daily_menu.store_daily_menu_photos.build
      }
    else
      redirect_to store_daily_menus_path(store_id:store_id),danger:'来月の献立を作成するので、山下に連絡ください！'
    end
  end

  def create
    @products = Product.where(brand_id:111)
    @store_daily_menu = StoreDailyMenu.new(store_daily_menu_params)

    date = @store_daily_menu.start_time
    store_id = @store_daily_menu.store_id
    @store = Store.find(store_id)
    daily_menu = DailyMenu.find_by(start_time:date)
    default_product_ids = [11429,13059]
    dmd_product_ids = default_product_ids
    @dmd_products = Product.where(id:dmd_product_ids)

    # @tommoroww = DailyMenu.find_by(start_time:date+1)
    # @yesterday = DailyMenu.find_by(start_time:date-1)
    @products = Product.where(brand_id:111)
    # @store_daily_menu_details = @store_daily_menu.products

    respond_to do |format|
      if @store_daily_menu.save
        format.html { redirect_to store_daily_menus_path(store_id:store_id), success: "登録OK！" }
        format.json { render :show, status: :created, location: @store_daily_menu }
      else
        format.html { render :new }
        format.json { render json: @store_daily_menu.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    def set_store_daily_menu
      @store_daily_menu = StoreDailyMenu.find(params[:id])
    end


    def store_daily_menu_params
      params.require(:store_daily_menu).permit(:start_time,:total_num,:weather,:max_temperature,:min_temperature,:opentime_showcase_photo,:event,:store_id,:daily_menu_id,
        :showcase_photo_a,:showcase_photo_b,:signboard_photo,:opentime_showcase_photo_uploaded,:editable_flag,
        store_daily_menu_photos_attributes: [:id,:store_daily_menu_id,:image],
        store_daily_menu_details_attributes: [:id,:store_daily_menu_id,:product_id,:number,:row_order,:_destroy,
          :actual_inventory,:carry_over,:sold_out_flag,:serving_plate_id,:signboard_flag,
          :pricecard_need_flag,:stock_deficiency_excess,:sozai_number,:bento_fukusai_number])
    end
end
