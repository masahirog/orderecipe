class AnalysesController < AdminController
  before_action :set_analysis, only: %i[ show edit update destroy ]
  def repeat
    params[:date]='2022-03-31'
    @date = Date.parse(params[:date])
    # month_days = ((date - 30)..date).to_a
    nyukai_members = SmaregiMember.where(nyukaibi:(@date - 30)..@date)
    nyukai_member_kaiin_ids = nyukai_members.map{|nm|nm.kaiin_id}

    @sths = SmaregiTradingHistory.where(torihiki_meisaikubun:1,torihikimeisai_id:1).where(kaiin_id:nyukai_member_kaiin_ids)
    @smaregi_member_counts = @sths.group(:kaiin_id).count
    @total_nyukaisyasu = @smaregi_member_counts.count
    @hash = {}
    @smaregi_member_counts.each do |smc|
      if @hash[smc[1]].present?
        @hash[smc[1]] += 1
      else
        @hash[smc[1]] = 1
      end
    end
    @hash = @hash.sort{|a, b|b[0] <=> a[0]}
  end

  def smaregi_member_csv
    smaregi_members = SmaregiMember.all
    @sths = SmaregiTradingHistory.where(torihiki_meisaikubun:1,torihikimeisai_id:1).where.not(kaiin_id:nil)
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "kaiin.csv", type: :csv
      end
    end
  end
  def upload_smaregi_members
    SmaregiMember.upload_data(params[:file])
    redirect_to smaregi_members_analyses_path, :notice => "スマレジ会員情報を更新しました"
  end
  def smaregi_member_group
    @all_stores = Store.all
    if params[:stores]
      checked_store_ids = params['stores'].keys
      @stores = @all_stores.where(id:checked_store_ids)
    else
      @stores = @all_stores
      checked_store_ids = @stores.ids
      params[:stores] = {}
      checked_store_ids.each do |store_id|
        params[:stores][store_id.to_s] = true
      end
    end
    smaregi_store_ids = @stores.map{|store|store.smaregi_store_id}
    smaregi_members = SmaregiMember.where(main_use_store:smaregi_store_ids)
    raiten_kaisu_count = smaregi_members.group(:raiten_kaisu).count.sort.to_h
    raiten_kaisu_arr = raiten_kaisu_count.keys
    raiten_count = raiten_kaisu_count.values
    gon.raiten_kaisu = raiten_kaisu_arr[0..4].push("5回以上")
    gon.raiten_count = raiten_count[0..4].push(raiten_count[5..-1].sum)
    member_sex = smaregi_members.group(:sex).count
    gon.sex = [member_sex['woman'],member_sex['man'],member_sex['minyuryoku']]
    birthday_done_smaregi_members = smaregi_members.where.not(birthday: nil)
    @count_saved_birthday = birthday_done_smaregi_members.count
    @count_un_saved_birthday = smaregi_members.where(birthday: nil).count
    now_year = Time.now.year
    age_users = [0,0,0,0,0,0,0]
    birthday_done_smaregi_members.each do |smaregi_member|
      birth_year = smaregi_member.birthday.year
      sa = now_year - birth_year
      if sa < 10
      elsif sa < 20
        age_users[0] = age_users[0] + 1
      elsif sa < 30
        age_users[1] = age_users[1] + 1
      elsif sa < 40
        age_users[2] = age_users[2] + 1
      elsif sa < 50
        age_users[3] = age_users[3] + 1
      elsif sa < 60
        age_users[4] = age_users[4] + 1
      elsif sa < 70
        age_users[5] = age_users[5] + 1
      else
        age_users[6] = age_users[6] + 1
      end
    end
    gon.age_users = age_users
    month_days = ((Date.today - 30)..Date.today).to_a
    nyukaibi_count = smaregi_members.where("nyukaibi >= ?",(Date.today - 30)).group(:nyukaibi).count
    ruikei_menber_count = smaregi_members.where("nyukaibi < ?",(Date.today - 30)).count
    gon.shinki_torokusu = []
    gon.ruiei_members = []
    gon.repeat_members = []
    month_days.each do |nc|
      if nyukaibi_count[nc].present?
        gon.shinki_torokusu << nyukaibi_count[nc]
        ruikei_menber_count += nyukaibi_count[nc]
        gon.ruiei_members << ruikei_menber_count
        # 2回目3回目のユーザーの処理を書く
      else
        gon.shinki_torokusu << 0
        gon.ruiei_members << ruikei_menber_count
      end
    end
    gon.month_days = month_days.map{|day|day.strftime("%-m/%-d")}

  end
  def orders
    @uniq_smaregi_trading_histories = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    kaiin_id = params[:kaiin_id]
    SmaregiTradingHistory.where(torihiki_meisaikubun:1,kaiin_id:kaiin_id).each do |sth|
      @uniq_smaregi_trading_histories[sth.torihiki_id][sth.id] = sth
    end
    @smaregi_member = SmaregiMember.find_by(kaiin_id:params[:kaiin_id])
  end
  def smaregi_members
    @stores = Store.all
    if params[:stores]
      checked_store_ids = params['stores'].keys
    else
      checked_store_ids = @stores.ids
      params[:stores] = {}
      @stores.each do |store|
        params[:stores][store.id.to_s] = true
      end
    end
    if params[:to]
      @to = params[:to].to_date
    else
      @to = Date.today
      params[:to] = @to
    end
    if params[:from]
      @from = params[:from].to_date
    else
      @from = @to - 30
      params[:from] = @from
    end
    @smaregi_members = SmaregiMember.all
    if params[:order].present?
      @smaregi_members = @smaregi_members.order("#{params[:order]} #{params[:sc]}")
    end
    @smaregi_members = @smaregi_members.page(params[:page]).per(50)
  end
  def product_sales
    @stores = Store.all
    if params[:stores]
      checked_store_ids = params['stores'].keys
    else
      checked_store_ids = @stores.ids
      params[:stores] = {}
      @stores.each do |store|
        params[:stores][store.id.to_s] = true
      end
    end
    if params[:to]
      @to = params[:to].to_date
    else
      @to = Date.today
      params[:to] = @to
    end
    if params[:from]
      @from = params[:from].to_date
    else
      @from = @to - 180
      params[:from] = @from
    end
    analyses = Analysis.where(date:@from..@to).where(store_id:checked_store_ids)
    @analysis_products = AnalysisProduct.where(analysis_id:analyses.ids,product_id:params[:product_id])
    @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @analysis_products.each do |ap|
      store_id = ap.analysis.store_id
      date = ap.analysis.date
      @hash[date][store_id]['early'] = ap.early_sales_number
      @hash[date][store_id]['total'] = ap.sales_number
    end
    @dates = @analysis_products.map{|ap|ap.analysis.date}.uniq.sort
  end
  def visitors_time_zone
    @stores = Store.all
    if params[:stores]
      checked_store_ids = params['stores'].keys
    else
      checked_store_ids = @stores.ids
      params[:stores] = {}
      @stores.each do |store|
        params[:stores][store.id.to_s] = true
      end
    end
    if params[:to]
      @to = params[:to].to_date
    else
      @to = Date.today
      params[:to] = @to
    end
    if params[:from]
      @from = params[:from].to_date
    else
      @from = @to - 30
      params[:from] = @from
    end
    analyses = Analysis.where(date:@from..@to).where(store_id:checked_store_ids)
    gon.time_zones = []
    gon.visitors_time_zone = []
    gon.average_visitors_time_zone = []
    ruikei = 0
    @dates = []
    @hours = []
    all_smaregi_trading_histories = SmaregiTradingHistory.where(analysis_id:analyses.ids)
    @dates_visitors = all_smaregi_trading_histories.select(:torihiki_id).distinct.group(:date).count
    @date_time_zorn_visitors = all_smaregi_trading_histories.select(:torihiki_id).distinct.group(:date).group("time_format(time, '%H')").count
    @date_time_zorn_visitors.keys.map do |date_hour|
      @dates << date_hour[0]
      @hours << date_hour[1]
    end
    @dates.uniq!
    @hours.uniq!
    @time_zone_visitors = all_smaregi_trading_histories.select(:torihiki_id).distinct.group("time_format(time, '%H')").count
    @time_zone_visitors.each do |tz|
      gon.time_zones << tz[0]
      gon.visitors_time_zone << tz[1]
      if tz[1].present?
        ruikei += tz[1]
        gon.average_visitors_time_zone << ((ruikei.to_f/@time_zone_visitors.values.sum)*100).round(1)
      else
        gon.average_visitors_time_zone << (ruikei.to_f/@dates.count)
        # gon.average_visitors_time_zone << ''
      end
    end
  end

  def recalculate_potential
    store_id = params[:store_id]
    product_id = params[:product_id]
    # 計算に直近2週間分の販売データを使用する
    potential_average = ProductSalesPotential.recalculate_potential(store_id,product_id)

    product_sales_potential = ProductSalesPotential.find_by(store_id:store_id,product_id:product_id)
    if product_sales_potential.present?
      product_sales_potential.update(sales_potential:potential_average)
    else
      ProductSalesPotential.create(store_id:store_id,product_id:product_id,sales_potential:potential_average)
    end
    redirect_to store_product_sales_analyses_path(store_id:store_id,product_id:product_id)
  end
  def store_product_sales
    @product = Product.find(params[:product_id])
    @store = Store.find(params[:store_id])
    @product_sales_potential= ProductSalesPotential.find_by(store_id:@store.id,product_id:@product.id)
    analysis_ids = @store.analyses
    @analysis_products = AnalysisProduct.joins(:analysis).order("analyses.date desc").where(product_id:@product.id,analysis_id:analysis_ids)
  end
  def store_products_sales
    @store = Store.find(params[:store_id])
    if params[:to]
      @to = params[:to].to_date
    else
      @to = Date.today
      params[:to] = @to
    end
    if params[:from]
      @from = params[:from].to_date
    else
      @from = @to - 30
      params[:from] = @from
    end
    @date_analyses = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @analyses = Analysis.where(date:@from..@to).where(store_id:params[:store_id])
    analysis_products = AnalysisProduct.includes([:product]).where(analysis_id:@analyses.ids).where.not(product_id:nil)
    product_ids = analysis_products.pluck(:product_id).uniq
    @products = Product.where(id:product_ids).order(:bejihan_sozai_flag)
    @product_datas = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    analysis_products.each do |ap|
      if ap.sales_number.present? && ap.actual_inventory.present?
        @product_datas[ap.product_id]['name'] = ap.product.name
        @product_datas[ap.product_id]['product_id'] = ap.product_id
        if params[:early_sales_number_flag]=='true'
          @product_datas[ap.product_id][ap.analysis_id]['sales_number'] = ap.early_sales_number
        else
          @product_datas[ap.product_id][ap.analysis_id]['sales_number'] = ap.sales_number
        end
        @product_datas[ap.product_id][ap.analysis_id]['actual_inventory'] = ap.actual_inventory
        # @product_datas[ap.product_id][ap.analysis_id]['date'] = ap.analysis.date
      end
    end

    if params[:sort]
      sort = params[:sort]
    else
      sort = 'sales_number'
    end
    if params[:sc]
      if params[:sc]=='asc'
        @product_datas = @product_datas.values.sort!{|a, b|a[sort] <=> b[sort]}
      else
        @product_datas = @product_datas.values.sort!{|a, b|b[sort] <=> a[sort]}
      end
    else
      @product_datas = @product_datas.values.sort!{|a, b|a[sort] <=> b[sort]}
    end
  end
  def bulk_delete_analysis_products
    # データ検証の商品情報を一括削除
    analysis_id = params[:analysis_id]
    analysis = Analysis.find(analysis_id)
    analysis_products = analysis.analysis_products
    count = analysis_products.count
    analysis_products.destroy_all
    redirect_to analysis, :alert => "#{count}件を削除しました。"

  end
  def smaregi_trading_history_totalling
    #アップロード済みのスマレジの販売履歴を計算する
    total_number_sales_sozai = 0
    fourteen_number_sales_sozai = 0
    analysis_id = params[:analysis]["analysis_id"]
    @analysis = Analysis.find(analysis_id)
    smaregi_shohin_ids = @analysis.analysis_products.map{|ap|ap.smaregi_shohin_id}
    smaregi_trading_histories = SmaregiTradingHistory.where(analysis_id:analysis_id)
    analysis_products_arr = []
    @product_sales_number = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    product_early_sales_number = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    smaregi_trading_histories.each do |sth|
      if sth.suryo.present?
        if sth.torihiki_meisaikubun == 1
          suryo = sth.suryo
          nebikigokei = sth.nebikigokei
        else
          suryo = -1 * sth.suryo
          nebikigokei = -1 * sth.nebikigokei
        end
        if @product_sales_number[sth.shohin_id].present?
          @product_sales_number[sth.shohin_id][:suryo] += suryo
          @product_sales_number[sth.shohin_id][:nebikigokei] += nebikigokei
        else
          @product_sales_number[sth.shohin_id][:suryo] = suryo
          @product_sales_number[sth.shohin_id][:nebikigokei] = nebikigokei
        end
        total_number_sales_sozai += suryo if sth.bumon_id == 1

        if sth.time.strftime('%H%M').to_i < 1400
          if product_early_sales_number[sth.shohin_id].present?
            product_early_sales_number[sth.shohin_id] += suryo
          else
            product_early_sales_number[sth.shohin_id] = suryo
          end
          fourteen_number_sales_sozai += suryo if sth.bumon_id == 1
        end
        if smaregi_shohin_ids.include?(sth.shohin_id)
        else
          new_analysis_product = AnalysisProduct.new(analysis_id:sth.analysis_id,smaregi_shohin_id:sth.shohin_id,smaregi_shohin_name:sth.shohinmei,smaregi_shohintanka:sth.shohintanka,
          product_id:sth.hinban,total_sales_amount:0,sales_number:0,loss_amount:0)
          analysis_products_arr << new_analysis_product
          smaregi_shohin_ids << sth.shohin_id
        end
      end
    end
    analysis_products_arr.each do |ap|
      ap.sales_number = @product_sales_number[ap.smaregi_shohin_id][:suryo]
      ap.total_sales_amount = @product_sales_number[ap.smaregi_shohin_id][:nebikigokei]
      if product_early_sales_number[ap.smaregi_shohin_id].present?
        ap.early_sales_number = product_early_sales_number[ap.smaregi_shohin_id]
        ap.potential = ((total_number_sales_sozai.to_f/fourteen_number_sales_sozai)*product_early_sales_number[ap.smaregi_shohin_id]).round(1)
      else
        ap.early_sales_number = 0
        ap.potential = 0
      end
    end
    AnalysisProduct.import analysis_products_arr
    redirect_to @analysis
  end
  def products
    #データ検証の商品情報を更新する
    total_loass_amount = 0
    analysis_id = params[:analysis]["analysis_id"]
    @analysis = Analysis.find(analysis_id)
    @store_daily_menu = StoreDailyMenu.find_by(start_time:@analysis.date,store_id:@analysis.store_id)
    smaregi_trading_histories = SmaregiTradingHistory.where(analysis_id:@analysis.id)
    product_day_sales_number = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    product_day_sales_amount = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    product_fourteen_sales_number = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    # product_day_sales_number = smaregi_trading_histories.group(:hinban).sum(:suryo)
    # product_early_sales_number = smaregi_trading_histories.where(time:'00:00:00'..'13:59:59').where(bumon_id:1).group(:hinban).sum(:suryo)
    update_analysis_products_arr = []
    new_analysis_products_arr = []

    smaregi_trading_histories.each do |sth|
      if sth.torihiki_meisaikubun == 1
        number = sth.suryo.to_i
        salse = sth.nebikigokei.to_i
      else
        number = -1 * sth.suryo.to_i
        salse = -1 * sth.nebikigokei.to_i
      end
      if product_day_sales_number[sth.hinban].present?
        product_day_sales_number[sth.hinban] += number
      else
        product_day_sales_number[sth.hinban] = number
      end
      if product_day_sales_amount[sth.hinban].present?
        product_day_sales_amount[sth.hinban] += salse
      else
        product_day_sales_amount[sth.hinban] = salse
      end
      if sth.time.strftime('%H%M').to_i < 1400
        if product_fourteen_sales_number[sth.hinban].present?
          product_fourteen_sales_number[sth.hinban] += number
        else
          product_fourteen_sales_number[sth.hinban] = number
        end
      end
    end


    @store_daily_menu.store_daily_menu_details.each do |sdmd|
      analysis_product = @analysis.analysis_products.find_by(product_id:sdmd.product_id)
      if analysis_product.present?
        analysis_product.list_price = sdmd.product.sell_price
        analysis_product.manufacturing_number = sdmd.number
        analysis_product.carry_over = sdmd.carry_over
        analysis_product.actual_inventory = sdmd.actual_inventory
        if product_day_sales_number[sdmd.product_id].present?
          analysis_product.sales_number = product_day_sales_number[sdmd.product_id]
        else
          analysis_product.sales_number = 0
        end
        if product_fourteen_sales_number[sdmd.product_id].present?
          analysis_product.early_sales_number = product_fourteen_sales_number[sdmd.product_id]
        else
          analysis_product.early_sales_number = 0
        end
        analysis_product.total_sales_amount = product_day_sales_amount[sdmd.product_id]
        analysis_product.loss_number = analysis_product.actual_inventory - analysis_product.sales_number
        loss_amount = ((analysis_product.list_price * analysis_product.loss_number)*1.08).floor(1)
        if loss_amount < 0 || analysis_product.product_id == 10459 || analysis_product.product_id == 12899
          analysis_product.loss_amount = 0
        else
          analysis_product.loss_amount = loss_amount
          total_loass_amount += loss_amount
        end
        update_analysis_products_arr << analysis_product
      else
        new_analysis_product = AnalysisProduct.new(analysis_id:analysis_id,product_id:sdmd.product_id,list_price:sdmd.product.sell_price,
          manufacturing_number:sdmd.number, carry_over:sdmd.carry_over,actual_inventory:sdmd.actual_inventory,loss_amount:0,loss_number:0)
        new_analysis_products_arr << new_analysis_product
      end
    end

    AnalysisProduct.import new_analysis_products_arr
    AnalysisProduct.import update_analysis_products_arr, on_duplicate_key_update:[:list_price,:manufacturing_number,:carry_over,:actual_inventory,
      :sales_number,:loss_number,:total_sales_amount,:loss_amount,:early_sales_number] if update_analysis_products_arr.present?
    @analysis.update(loss_amount:total_loass_amount)
    redirect_to @analysis
  end
  def date
    @date = params[:date]
    @stores = Store.all
    @analyses_hash = {}
    Analysis.where(date:@date).each do |analysis|
      @analyses_hash[analysis.store_id] = analysis
    end

  end
  def summary
    @stores = Store.all
    if params[:stores]
      checked_store_ids = params['stores'].keys
    else
      checked_store_ids = @stores.ids
      params[:stores] = {}
      @stores.each do |store|
        params[:stores][store.id.to_s] = true
      end
    end
    if params[:to]
      @to = params[:to].to_date
    else
      @to = Date.today
      params[:to] = @to
    end
    if params[:from]
      @from = params[:from].to_date
    else
      @from = @to - 30
      params[:from] = @from
    end
    gon.dates = (@from..@to).map{|date|date}
    @date_analyses = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    analyses = Analysis.where(date:@from..@to).where(store_id:checked_store_ids)
    analysis_products = AnalysisProduct.includes([:product,:analysis]).where(analysis_id:analyses.ids).where.not(product_id:nil)
    product_ids = analysis_products.pluck(:product_id).uniq
    @products = Product.where(id:product_ids).order(:bejihan_sozai_flag)
    @product_datas = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    analysis_products.each do |ap|
      if ap.sales_number.present? && ap.actual_inventory.present?
        if @product_datas[ap.product_id].present?
          @product_datas[ap.product_id]['sales_number'] += ap.sales_number
          @product_datas[ap.product_id]['actual_inventory'] += ap.actual_inventory
          @product_datas[ap.product_id]['count'] += 1
        else
          @product_datas[ap.product_id]['name'] = ap.product.name
          @product_datas[ap.product_id]['sales_number'] = ap.sales_number
          @product_datas[ap.product_id]['actual_inventory'] = ap.actual_inventory
          @product_datas[ap.product_id]['count'] = 1
          @product_datas[ap.product_id]['product_id'] = ap.product_id
          @product_datas[ap.product_id]['date'] = ap.analysis.date
        end
      end
    end
    # score計算
    all_smaregi_trading_histories = SmaregiTradingHistory.where(analysis_id:analyses.ids)
    @day_sales_number = all_smaregi_trading_histories.group(:hinban).sum(:suryo)
    @early_sales_number = all_smaregi_trading_histories.where(time:'00:00:00'..'13:59:59').group(:hinban).sum(:suryo)
    @middle_sales_number = all_smaregi_trading_histories.where(time:'14:00:00'..'18:59:59').group(:hinban).sum(:suryo)
    @late_sales_number = all_smaregi_trading_histories.where(time:'19:00:00'..'23:59:59').group(:hinban).sum(:suryo)

    @product_datas.each do |pd|
      if pd[1]['actual_inventory'] == 0
      else
        pd[1]['sales_rate'] = ((pd[1]['sales_number'].to_f / pd[1]['actual_inventory'])*100).round
      end
    end

    if params[:sort]
      sort = params[:sort]
    else
      sort = 'sales_number'
    end
    if params[:sc]
      if params[:sc]=='asc'
        @product_datas = @product_datas.values.sort!{|a, b|a[sort] <=> b[sort]}
      else
        @product_datas = @product_datas.values.sort!{|a, b|b[sort] <=> a[sort]}
      end
    else
      @product_datas = @product_datas.values.sort!{|a, b|a[sort] <=> b[sort]}
    end


    analyses.each do |analysis|
      @date_analyses[analysis.date][analysis.store_id] = analysis
    end
    @date_transaction_count = analyses.group(:date).sum(:transaction_count)
    @date_sales_amount = analyses.group(:date).sum(:sales_amount)
    @date_loss_amount = analyses.group(:date).sum(:loss_amount)
    date_arr = []
    data_arr = []
    data_loss_arr = []
    date_transaction_count_arr = []
    haiki_mokuhyo_arr = []
    data_lossamount_arr = []
    @date_sales_amount.sort.each do |date_sales|
      date_arr << date_sales[0].strftime("%-m/%-d (#{%w(日 月 火 水 木 金 土)[date_sales[0].wday]})")
      data_arr << date_sales[1]
      data_lossamount_arr << @date_loss_amount[date_sales[0]]
      data_loss_arr << ((@date_loss_amount[date_sales[0]].to_f/date_sales[1])*100).round(1)
      date_transaction_count_arr << @date_transaction_count[date_sales[0]]
      haiki_mokuhyo_arr << 6
    end
    gon.sales_dates = date_arr
    gon.sales_data = data_arr
    gon.loss_data = data_loss_arr
    gon.loss_mokuhyo_data = haiki_mokuhyo_arr
    gon.transaction_count_date = date_transaction_count_arr
    gon.lossamount_data = data_lossamount_arr
  end

  def index
    @stores = Store.all
    if params[:stores]
      checked_store_ids = params['stores'].keys
    else
      checked_store_ids = @stores.ids
      params[:stores] = {}
      @stores.each do |store|
        params[:stores][store.id.to_s] = true
      end
    end
    if params[:to]
      @to = params[:to].to_date
    else
      @to = Date.today
      params[:to] = @to
    end
    if params[:from]
      @from = params[:from].to_date
    else
      @from = @to - 30
      params[:from] = @from
    end
    @period = (@to - @from).to_i
    @analyses = Analysis.includes([:store,analysis_products:[:product]]).where(date:@from..@to).where(store_id:checked_store_ids).order(:date)
    @date_sales_amount = @analyses.group(:date).sum(:sales_amount)
    @date_loss_amount = @analyses.group(:date).sum(:loss_amount)
    @date_transaction_count = @analyses.group(:date).sum(:transaction_count)
    @date_sales_number = @analyses.group(:date).sum(:transaction_count)
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "べじはん販売データ.csv", type: :csv
      end
    end
  end

  def show
    @or_ari_analysis_products = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @or_nashi_analysis_products = []
    @shohin_id = params[:shohin_id]
    @hinban = params[:hinban]
    @shohinmei = params[:shohinmei]
    @smaregi_trading_histories = SmaregiTradingHistory.all
    @smaregi_trading_histories = @smaregi_trading_histories.where(analysis_id:@analysis.id)
    @shohin_ids = @smaregi_trading_histories.map{|sth|sth.shohin_id}.uniq
    @product_ids = @smaregi_trading_histories.map{|sth|sth.hinban}.uniq
    @shohinmeis = @smaregi_trading_histories.map{|sth|sth.shohinmei}.uniq
    @smaregi_trading_histories = @smaregi_trading_histories.where(shohin_id:@shohin_id) if @shohin_id.present?
    @smaregi_trading_histories = @smaregi_trading_histories.where(hinban:@hinban) if @hinban.present?
    @smaregi_trading_histories = @smaregi_trading_histories.where(shohinmei:@shohinmei) if @shohinmei.present?
    @smaregi_trading_histories = @smaregi_trading_histories.order(shohinmei:'asc') if params[:row_order] == 'asc'
    # @date_counts = @smaregi_trading_histories.group(:date).count()

    @smaregi_trading_histories = @smaregi_trading_histories.page(params[:page]).per(50)

    date = @analysis.date
    store_id = @analysis.store_id
    @store_daily_menu = StoreDailyMenu.find_by(start_time:date,store_id:store_id)
    @store_daily_menu_details = @store_daily_menu.store_daily_menu_details.includes([:product]).order(:row_order)
    sdmd_arr = @store_daily_menu_details.map{|sdmd|sdmd.product_id}
    @analysis.analysis_products.includes(:product).each do |ap|
      if sdmd_arr.include?(ap.product_id)
        if @or_ari_analysis_products[ap.product_id].present?
          @or_nashi_analysis_products << ap
        else
          @or_ari_analysis_products[ap.product_id] = ap
        end
      else
        @or_nashi_analysis_products << ap
      end
    end
  end

  def new
    @analysis = Analysis.new(store_id:params[:store_id],date:params[:date])
  end

  def edit
  end

  def create
    @analysis = Analysis.new(analysis_params)
    respond_to do |format|
      if @analysis.save
        format.html { redirect_to @analysis, notice: "Analysis was successfully created." }
        format.json { render :show, status: :created, location: @analysis }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @analysis.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @analysis.update(analysis_params)
        format.html { redirect_to @analysis, notice: "Analysis was successfully updated." }
        format.json { render :show, status: :ok, location: @analysis }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @analysis.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @analysis.destroy
    respond_to do |format|
      format.html { redirect_to analyses_url, notice: "Analysis was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_analysis
      @analysis = Analysis.find(params[:id])
    end

    def analysis_params
      params.require(:analysis).permit(:store_id,:date)
    end
end
