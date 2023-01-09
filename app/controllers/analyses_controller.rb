class AnalysesController < AdminController
  before_action :set_analysis, only: %i[ show edit update destroy ]
  # def onceupload
  #   first_day = Date.parse(params[:from])
  #   last_day = Date.parse(params[:to])
  #   store_id = params[:store_id]
  #   update_datas_count = SmaregiTradingHistory.once_uploads_data(params[:file],first_day,last_day,store_id)
  #   redirect_to smaregi_trading_histories_path()
  # end

  def progress
    @analysis = Analysis.find(params[:analysis_id])
    if params[:to]
      @to = params[:to].to_date
    else
      @to = Date.today - 1
      params[:to] = @to
    end
    if params[:from]
      @from = params[:from].to_date
    else
      @from = @to - 30
      params[:from] = @from
    end
    @dates =(@from..@to).to_a
    if @to == @from
      @period = 1
    else
      @period = (@to - @from).to_i
    end
    @smaregi_store_id = @analysis.store_daily_menu.store.smaregi_store_id
    uchikeshi_torihiki_ids = SmaregiTradingHistory.where(date:@from..@to).where(uchikeshi_kubun:2).map{|sth|sth.uchikeshi_torihiki_id}.uniq
    smaregi_trading_histories = SmaregiTradingHistory.where(date:@from..@to).where(tenpo_id:@smaregi_store_id,torihiki_meisaikubun:1).where.not(torihiki_id:uchikeshi_torihiki_ids)
    @time_zone_sales = smaregi_trading_histories.group("date_format(time, '%H')").sum(:zeinuki_uriage)
    @time_zone_counts = smaregi_trading_histories.group("date_format(time, '%H')").distinct.count(:torihiki_id)
    @time_zone_sales_product = smaregi_trading_histories.group("date_format(time, '%H')").group(:bumon_id).sum(:suryo)
    @time_zone_nebikigaku_gokei = smaregi_trading_histories.group("date_format(time, '%H')").sum(:tanka_nebikikei)
    @time_zone_nebikisu_gokei = smaregi_trading_histories.where("tanka_nebikikei >0").group("date_format(time, '%H')").sum(:suryo)
    @store_daily_menu = @analysis.store_daily_menu
    @initial_sozai_num = @store_daily_menu.store_daily_menu_details.joins(:product).where(:products =>{product_category:1}).sum(:sozai_number)
    @initial_bento_num = @store_daily_menu.store_daily_menu_details.joins(:product).where(:products =>{product_category:5}).sum(:sozai_number)
    date = @store_daily_menu.start_time
    today_uchikeshi_torihiki_ids = SmaregiTradingHistory.where(date:date).where(uchikeshi_kubun:2).map{|sth|sth.uchikeshi_torihiki_id}.uniq
    today_smaregi_trading_histories = SmaregiTradingHistory.where(date:date).where(torihiki_meisaikubun:1).where.not(torihiki_id:today_uchikeshi_torihiki_ids)
    @today_time_zone_sales = today_smaregi_trading_histories.group("date_format(time, '%H')").sum(:zeinuki_uriage)
    @today_time_zone_counts = today_smaregi_trading_histories.group("date_format(time, '%H')").distinct.count(:torihiki_id)
    @today_time_zone_sales_product = today_smaregi_trading_histories.group("date_format(time, '%H')").group(:bumon_id).sum(:suryo)
    @today_time_zone_nebikigaku_gokei = today_smaregi_trading_histories.group("date_format(time, '%H')").sum(:tanka_nebikikei)
    @today_time_zone_nebikisu_gokei = today_smaregi_trading_histories.where("tanka_nebikikei >0").group("date_format(time, '%H')").sum(:suryo)
    @time = today_smaregi_trading_histories.maximum(:torihiki_nichiji)
    @today_bento_sales = today_smaregi_trading_histories.where("time < ?", "#{@time.hour}:00:00").where(bumon_id:5).sum(:suryo)
    @today_sozai_sales = today_smaregi_trading_histories.where("time < ?", "#{@time.hour}:00:00").where(bumon_id:1).sum(:suryo)
    @today_bento_sales_yoso = (smaregi_trading_histories.where("time > ?", "#{@time.hour}:00:00").where(bumon_id:5).sum(:suryo)/@period)
    @today_sozai_sales_yoso = (smaregi_trading_histories.where("time > ?", "#{@time.hour}:00:00").where(bumon_id:1).sum(:suryo)/@period)

  end

  def gyusuji
    @stores = Store.where.not(id:39)
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
      params[:to] = params[:to].to_date
    else
      params[:to] = Date.today - 1
    end
    if params[:from]
      params[:from] = params[:from].to_date
    else
      params[:from] = params[:to] - 13 unless params[:from]
    end
    @dates =(params[:from]..params[:to]).to_a
    analyses = Analysis.where(date:@dates).where(store_id:checked_store_ids)
    all_smaregi_trading_histories = SmaregiTradingHistory.where(analysis_id:analyses.ids)
    @gyusuji_sales_data = all_smaregi_trading_histories.where(torihiki_meisaikubun:1,shohin_id:[354,355,373,742,374]).group(:date,:shohin_id).sum(:suryo)
    @gyusuji_henpin_data = all_smaregi_trading_histories.where(torihiki_meisaikubun:2,shohin_id:[354,355,373,742,374]).group(:date,:shohin_id).sum(:suryo)
    @total_gyusuji_sales_data = all_smaregi_trading_histories.where(torihiki_meisaikubun:1,shohin_id:[354,355,373,742,374]).group(:shohin_id).sum(:suryo)
    @total_gyusuji_henpin_data = all_smaregi_trading_histories.where(torihiki_meisaikubun:2,shohin_id:[354,355,373,742,374]).group(:shohin_id).sum(:suryo)

    @shohin_id_name = {354 => "煮玉子",355=>"肉増し",373=>"丼",742=>"大根",374=>"牛すじ単品"}
  end
  def labor
    today = Date.today
    @dates = (today-30..today)
    @daily_working_hours = WorkingHour.where(date:@dates).group(:store_id,:date).sum(:working_time)
    @analyses = Analysis.where(date:@dates).map{|analysis|[[analysis.store_daily_menu.start_time,analysis.store_daily_menu.store_id],analysis.total_sales_amount]}.to_h
    @total_analyses = Analysis.where(date:@dates).group(:date).sum(:total_sales_amount)
    @kurumesis = KurumesiOrder.where(start_time:@dates,canceled_flag:false).group(:start_time).sum("total_price")
    gon.dates = []
    gon.labor_data =[]
    (today-30..today).map do |date|
      gon.dates << date.strftime('%y/%m/%d')
      gon.labor_data << @daily_working_hours[[39,date]]
    end
    @working_hours = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @week_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @weekday_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @weekend_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    WorkingHour.where(store_id:39).where(date:today-180..today).each do |wh|
      if wh.date.wday >= 3
        wednesday = wh.date - (wh.date.wday - 3)
      elsif wh.date.wday < 3
        wednesday = wh.date - (wh.date.wday + 4)
      end
      if @week_hash[wednesday].present?
        @week_hash[wednesday]['time'] += wh.working_time.to_f
      else
        @week_hash[wednesday]['time'] = wh.working_time.to_f
      end

      if wh.date.wday == 0 || wh.date.wday == 6
        if @weekend_hash[wednesday].present?
          @weekend_hash[wednesday]['time'] += wh.working_time.to_f
        else
          @weekend_hash[wednesday]['time'] = wh.working_time.to_f
        end
      else
        if @weekday_hash[wednesday].present?
          @weekday_hash[wednesday]['time'] += wh.working_time.to_f
        else
          @weekday_hash[wednesday]['time'] = wh.working_time.to_f
        end
      end
    end
    gon.wednesdays = []
    gon.week_work_time = []
    gon.weekday_work_time = []
    gon.weekend_work_time = []
    (today-180..today).each do |date|
      if date.wday == 3
        gon.wednesdays << date
        gon.weekday_work_time << (@weekday_hash[date]["time"]/5).round(1) if @weekday_hash[date]["time"].present?
        gon.weekend_work_time << (@weekend_hash[date]["time"]/2).round(1) if @weekend_hash[date]["time"].present?
        gon.week_work_time << (@week_hash[date]["time"]/7).round(1) if @week_hash[date]["time"].present?
      end
    end
    @wednesdays = gon.wednesdays
    @staffs = WorkingHour.where(date:@dates,group_id:19).order(:jobcan_staff_code).pluck(:name).uniq
    WorkingHour.where(date:@dates,group_id:19).each do |wh|
      if wh.working_time.to_f > 8
        zangyo = wh.working_time - 8
      else
        zangyo = 0
      end
      if @working_hours[wh.name].present?
        @working_hours[wh.name]["zangyo"] += zangyo
        @working_hours[wh.name]["date"][wh.date] = wh.working_time
        @working_hours[wh.name]["sum"] += wh.working_time.to_f
        @working_hours[wh.name]["count"] += 1
        if wh.date > (today - 7)
          @working_hours[wh.name]["seven_sum"] += wh.working_time.to_f
          @working_hours[wh.name]["seven_zangyo"] += zangyo
          @working_hours[wh.name]["seven_count"] += 1
        end
      else
        @working_hours[wh.name]["zangyo"] = zangyo
        @working_hours[wh.name]["sum"] = wh.working_time.to_f
        @working_hours[wh.name]["count"] = 1
        @working_hours[wh.name]["date"][wh.date] = wh.working_time.to_f
        if wh.date > (today - 7)
          @working_hours[wh.name]["seven_sum"] = wh.working_time.to_f
          @working_hours[wh.name]["seven_count"] = 1
          @working_hours[wh.name]["seven_zangyo"] = zangyo
        else
          @working_hours[wh.name]["seven_sum"] = 0
          @working_hours[wh.name]["seven_zangyo"] = 0
          @working_hours[wh.name]["seven_count"] = 0
        end
      end
    end
  end
  def timezone_sales
    if params[:stores]
      checked_store_ids = params['stores'].keys
      @stores = Store.where(id:checked_store_ids)
    else
      @stores = Store.where(group_id:9)
      checked_store_ids = @stores.ids
      params[:stores] = {}
      @stores.each do |store|
        params[:stores][store.id.to_s] = true
      end
    end
    if params[:to]
      @to = params[:to].to_date
    else
      @to = Date.today - 1
      params[:to] = @to
    end
    if params[:from]
      @from = params[:from].to_date
    else
      @from = @to - 30
      params[:from] = @from
    end
    @dates =(@from..@to).to_a
    if @to == @from
      @period = 1
    else
      @period = (@to - @from).to_i
    end
    uchikeshi_torihiki_ids = SmaregiTradingHistory.where(date:@from..@to).where(uchikeshi_kubun:2).map{|sth|sth.uchikeshi_torihiki_id}.uniq
    smaregi_trading_histories = SmaregiTradingHistory.where(date:@from..@to).where(torihiki_meisaikubun:1).where.not(torihiki_id:uchikeshi_torihiki_ids)
    @time_zone_sales = smaregi_trading_histories.group("date_format(time, '%H')").group(:tenpo_id).sum(:zeinuki_uriage)
    @time_zone_counts = smaregi_trading_histories.group("date_format(time, '%H')").group(:tenpo_id).distinct.count(:torihiki_id)
    @time_zone_sales_product = smaregi_trading_histories.group("date_format(time, '%H')").group(:tenpo_id,:bumon_id).sum(:suryo)
    @time_zone_nebikigaku_gokei = smaregi_trading_histories.group("date_format(time, '%H')").group(:tenpo_id).sum(:tanka_nebikikei)
    @time_zone_nebikisu_gokei = smaregi_trading_histories.where("tanka_nebikikei >0").group("date_format(time, '%H')").group(:tenpo_id).sum(:suryo)
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "べじはん販売データ.csv", type: :csv
      end
    end
  end


  def staffs
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
    @group = Group.find(9)
    store_ids = @group.stores.ids
    @stores = Store.where(id:store_ids)
    @fix_shift_patterns = FixShiftPattern.where(group_id:@group.id)
    @staffs = Staff.where(status:0,store_id:store_ids).order(:row)
    @jobcounts = Shift.where(date:@from..@to).where.not(fix_shift_pattern_id:nil).group(:staff_id).count
    @clean_done = Reminder.where(category:1).where(action_date:@from..@to).group(:do_staff).count
    smaregi_members = SmaregiMember.where(nyukaibi:@from..@to)
    kaiin_ids = smaregi_members.map{|sm|sm.kaiin_id}
    @hash = {}
    SmaregiTradingHistory.order("date desc").where(kaiin_id:kaiin_ids).where(date:@from..@to).where(torihikimeisai_id:1).each do |sth|
      @hash[sth.kaiin_id] = sth
    end
    @staff_sinki_kaiin = {}
    @hash.values.each do |sth|
      if @staff_sinki_kaiin[sth.hanbaiin_id].present?
        @staff_sinki_kaiin[sth.hanbaiin_id] += 1
      else
        @staff_sinki_kaiin[sth.hanbaiin_id] = 1
      end
    end
  end
  def stores
    if params[:date].present?
      @date = params[:date].to_date
    else
      @date = Date.today
    end
    @stores = Store.where(group_id:9)
    @store_daily_menus = StoreDailyMenu.where(start_time:@date)
    @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @store_daily_menus.each do |sdm|
      am_ten_serving_done_product = StoreDailyMenuDetailHistory.where('created_at < ?',DateTime.parse(@date.to_s + " 10:00:00 +09:00") ).where(store_daily_menu_detail_id:sdm.store_daily_menu_details.ids).select(:store_daily_menu_detail_id).distinct.count
      am_eleven_serving_done_product = StoreDailyMenuDetailHistory.where('created_at < ?',DateTime.parse(@date.to_s + " 11:00:00 +09:00") ).where(store_daily_menu_detail_id:sdm.store_daily_menu_details.ids).select(:store_daily_menu_detail_id).distinct.count
      store_showcase_completion_rate_at_ten = ((am_ten_serving_done_product.to_f / sdm.store_daily_menu_details.count)*100).round(1)
      store_showcase_completion_rate_at_eleven = ((am_eleven_serving_done_product.to_f / sdm.store_daily_menu_details.count)*100).round(1)
      @hash[sdm.store_id][:store_showcase_completion_rate_at_ten] = store_showcase_completion_rate_at_ten
      @hash[sdm.store_id][:store_showcase_completion_rate_at_eleven] = store_showcase_completion_rate_at_eleven
      @hash[sdm.store_id][:sdm] = sdm
      if sdm.store_daily_menu_details.find_by(product_id:13649).store_daily_menu_detail_histories.present?
        @hash[sdm.store_id][:bento_finish_time] = sdm.store_daily_menu_details.find_by(product_id:13649).store_daily_menu_detail_histories[0].created_at
      else
        @hash[sdm.store_id][:bento_finish_time] = nil
      end
    end

    #掃除
    bow = @date.beginning_of_week
    bom = @date.beginning_of_month
    @weekly_clean_reminders_count = Reminder.where(action_date:bow,category:1).group(:store_id).count
    @done_weekly_clean_reminders = Reminder.where(action_date:bow,category:1,status:'done').group(:store_id).count
    @last_weekly_clean_reminders_count = Reminder.where(action_date:(bow-7),category:1).group(:store_id).count
    @done_last_weekly_clean_reminders = Reminder.where(action_date:(bow-7),category:1,status:'done').group(:store_id).count
    @monthly_clean_reminders_count = Reminder.where(action_date:bow,category:1).group(:store_id).count
    @done_monthly_clean_reminders = Reminder.where(action_date:bom,category:1,status:'done').group(:store_id).count
    #会員
    @today_new_user = SmaregiMember.where(nyukaibi:@date).group(:main_use_store).count.map{|k,v|[SmaregiMember.main_use_stores[k],v]}.to_h
    @month_new_user = SmaregiMember.where(nyukaibi:bom..@date).group(:main_use_store).count.map{|k,v|[SmaregiMember.main_use_stores[k],v]}.to_h
    @last_month_new_user = SmaregiMember.where(nyukaibi:@date.last_month.all_month).group(:main_use_store).count.map{|k,v|[SmaregiMember.main_use_stores[k],v]}.to_h
    @total_user = SmaregiMember.all.group(:main_use_store).count.map{|k,v|[SmaregiMember.main_use_stores[k],v]}.to_h

    #来客
    @today_raikyakusu = SmaregiTradingHistory.where(date:@date,torihiki_meisaikubun:1,torihikimeisai_id:1).group(:tenpo_id).count
    @yesterday_raikyakusu = SmaregiTradingHistory.where(date:@date-1,torihiki_meisaikubun:1,torihikimeisai_id:1).group(:tenpo_id).count
    @month_raikyakusu = SmaregiTradingHistory.where(date:bom..@date,torihiki_meisaikubun:1,torihikimeisai_id:1).group(:tenpo_id).count
    @last_month_raikyakusu = SmaregiTradingHistory.where(date:@date.last_month.all_month,torihiki_meisaikubun:1,torihikimeisai_id:1).group(:tenpo_id).count

    #廃棄
    # analyses = Analysis.where(date:date)
    @date_sales_amount = Analysis.where(date:@date).group(:store_id).sum(:ex_tax_sales_amount)
    @date_loss_amount = Analysis.where(date:@date).group(:store_id).sum(:loss_amount)
    @date_discount_amount = Analysis.where(date:@date).group(:store_id).sum(:discount_amount)

    @month_sales_amount = Analysis.where(date:bom..@date).group(:store_id).sum(:ex_tax_sales_amount)
    @month_loss_amount = Analysis.where(date:bom..@date).group(:store_id).sum(:loss_amount)
    @month_discount_amount = Analysis.where(date:bom..@date).group(:store_id).sum(:discount_amount)
    @last_month_sales_amount = Analysis.where(date:@date.last_month.all_month).group(:store_id).sum(:ex_tax_sales_amount)
    @last_month_loss_amount = Analysis.where(date:@date.last_month.all_month).group(:store_id).sum(:loss_amount)
    @last_month_discount_amount = Analysis.where(date:@date.last_month.all_month).group(:store_id).sum(:discount_amount)
    # @store_date_loss_amount = analyses.group(:date,:store_id).sum(:loss_amount)

  end
  def update_sales_data_smaregi_members
    SmaregiMember.update_sales_data
    redirect_to smaregi_members_analyses_path,notice:'更新しました。'
  end
  def sales
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
    @dates =(@from..@to).to_a
    @period = (@to - @from).to_i
    @analyses = Analysis.where(date:@from..@to).where(store_id:checked_store_ids).order(:date)
    @date_sales_amount = @analyses.group(:date).sum(:ex_tax_sales_amount)
    @date_loss_amount = @analyses.group(:date).sum(:loss_amount)
    @date_transaction_count = @analyses.group(:date).sum(:transaction_count)
    @date_sales_number = @analyses.group(:date).sum(:transaction_count)
    @date_discount_amount = @analyses.group(:date).sum(:discount_amount)
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "べじはん販売データ.csv", type: :csv
      end
    end
  end
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
    @smaregi_members = SmaregiMember.all
    # @sths = SmaregiTradingHistory.where(torihiki_meisaikubun:1,torihikimeisai_id:1).where.not(kaiin_id:nil)
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "kaiin.csv", type: :csv
      end
    end
  end
  def smaregi_sales_csv
    @sths = SmaregiTradingHistory.where.not(kaiin_id:nil).select(:torihiki_id,:torihiki_meisaikubun,:kaiin_id,:date).order("date ASC").distinct(:torihiki_id)
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
  def member


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
    if params[:store_ids].present?
      params[:stores] = {}
      checked_store_ids = params['store_ids']
      @stores = Store.where(id:checked_store_ids)
      @stores.each do |store|
        params[:stores][store.id.to_s] = true
      end
    elsif params[:stores].present?
      checked_store_ids = params['stores'].keys
      @stores = Store.where(id:checked_store_ids)
      params[:store_ids] = checked_store_ids
    else
      params[:stores] = {}
      @stores = Store.all
      checked_store_ids = @stores.ids
      params[:store_ids] = checked_store_ids
      @stores.each do |store|
        params[:stores][store.id.to_s] = true
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
    @smaregi_members = SmaregiMember.where(main_use_store:@stores.map{|store|store.smaregi_store_id})
    # @smaregi_members = SmaregiMember.all
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
      @from = @to - 30
      params[:from] = @from
    end
    analyses = Analysis.where(date:@from..@to).where(store_id:checked_store_ids)
    @analysis_products = AnalysisProduct.includes([:analysis]).where(analysis_id:analyses.ids)
    @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @dates = []
    product_ids = []
    @analysis_products.each do |ap|
      if @hash[ap.product_id][ap.analysis.store_daily_menu.start_time].present?
        @hash[ap.product_id][ap.analysis.store_daily_menu.start_time][:actual_inventory] += ap.actual_inventory.to_i
        @hash[ap.product_id][ap.analysis.store_daily_menu.start_time][:sales_number] += ap.sales_number
        @hash[ap.product_id][ap.analysis.store_daily_menu.start_time][:total_sales_amount] += ap.total_sales_amount
        @hash[ap.product_id][ap.analysis.store_daily_menu.start_time][:discount_amount] += ap.discount_amount
        @hash[ap.product_id][ap.analysis.store_daily_menu.start_time][:loss_amount] += ap.loss_amount
      else
        @hash[ap.product_id][ap.analysis.store_daily_menu.start_time] = {sales_number:ap.sales_number,total_sales_amount:ap.total_sales_amount,discount_amount:ap.discount_amount,loss_amount:ap.loss_amount,actual_inventory:ap.actual_inventory.to_i}
        product_ids << ap.product_id unless product_ids.include?(ap.product_id)
        @dates << ap.analysis.store_daily_menu.start_time unless @dates.include?(ap.analysis.store_daily_menu.start_time)
      end
    end
    @dates = @dates.sort
    @products = Product.where(id:product_ids)
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
        # @product_datas[ap.product_id][ap.analysis_id]['date'] = ap.analysis.store_daily_menu.start_time
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
    analysis_id = params[:analysis_id]
    analysis = Analysis.find(analysis_id)
    update_datas_count = SmaregiTradingHistory.recalculate(analysis_id)
    redirect_to analysis
  end
  def date
    @date = params[:date]
    @stores = Store.all
    @analyses_hash = {}
    Analysis.where(date:@date).each do |analysis|
      @analyses_hash[analysis.store_daily_menu.store_id] = analysis
    end
    @store_daily_menus_hash = StoreDailyMenu.where(start_time:@date).map{|sdm|[sdm.store_id,sdm.id]}.to_h
  end
  def summary
    gon.lat = 35.7058146
    gon.lon = 139.6657874
    gon.api = ENV['WEATHER_API']
    @stores = Store.where.not(id:39)
    unless params[:stores]
      params[:stores] = {}
      @stores.each{|store|params[:stores][store.id.to_s] = true}
    end
    if params[:to]
      params[:to] = params[:to].to_date
    else
      params[:to] = Date.today
    end
    if params[:from]
      params[:from] = params[:from].to_date
    else
      params[:from] = params[:to] - 30 unless params[:from]
    end
    @dates =(params[:from]..params[:to]).to_a
    @analyses = Analysis.includes([:store_daily_menu]).where(date:params[:from]..params[:to]).where(store_id:params['stores'].keys)
    @store_analyses = @analyses.map{|analysis|[[analysis.store_daily_menu.start_time,analysis.store_daily_menu.store_id],analysis]}.to_h
    analysis_event_sales = AnalysisCategory.where(analysis_id:@analyses.ids,smaregi_bumon_id:6).map{|ac|[ac.analysis_id,ac.ex_tax_sales_amount]}.to_h
    @date_analyses = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @date_store_analyses = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @analyses.each do |analysis|
      if analysis.ex_tax_sales_amount.present?
        ex_tax_sales_amount = analysis.ex_tax_sales_amount
      else
        ex_tax_sales_amount = 0
      end
      if analysis_event_sales[analysis.id].present?
        event_sales = analysis_event_sales[analysis.id]
      else
        event_sales = 0
      end
      if @date_store_analyses[analysis.date][analysis.store_id].present?
        if params[:add_event]=="true"
          @date_store_analyses[analysis.date][analysis.store_id][:sales_amount] += analysis.ex_tax_sales_amount
        else
          @date_store_analyses[analysis.date][analysis.store_id][:sales_amount] += (ex_tax_sales_amount - event_sales)
        end
        @date_store_analyses[analysis.date][analysis.store_id][:discount_amount] += analysis.discount_amount
        @date_store_analyses[analysis.date][analysis.store_id][:loss_amount] += analysis.loss_amount
        @date_store_analyses[analysis.date][analysis.store_id][:transaction_count] += analysis.transaction_count
        @date_store_analyses[analysis.date][analysis.store_id][:sales_number] += analysis.transaction_count
      else
        if params[:add_event]=="true"
          @date_store_analyses[analysis.date][analysis.store_id][:sales_amount] = analysis.ex_tax_sales_amount
        else
          @date_store_analyses[analysis.date][analysis.store_id][:sales_amount] = (ex_tax_sales_amount - event_sales)
        end
        @date_store_analyses[analysis.date][analysis.store_id][:discount_amount] = analysis.discount_amount
        @date_store_analyses[analysis.date][analysis.store_id][:loss_amount] = analysis.loss_amount
        @date_store_analyses[analysis.date][analysis.store_id][:transaction_count] = analysis.transaction_count
        @date_store_analyses[analysis.date][analysis.store_id][:sales_number] = analysis.transaction_count
      end
    end

    gon.sales_dates = @dates
    gon.sales_data = []
    gon.loss_data = []
    gon.loss_mokuhyo_data = []
    @dates.sort.each do |date|
      gon.sales_data << @date_store_analyses[date].map{|hash|hash[1][:sales_amount]}.sum
      gon.loss_data << (((@date_store_analyses[date].map{|hash|hash[1][:discount_amount].to_i}.sum.to_f + @date_store_analyses[date].map{|hash|hash[1][:loss_amount].to_i}.sum.to_f)/@date_store_analyses[date].map{|hash|hash[1][:sales_amount]}.sum)*100).round(1)
      gon.loss_mokuhyo_data << 7
    end
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "べじはん販売データ.csv", type: :csv
      end
    end
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
    @analyses = Analysis.where(date:@from..@to).where(store_id:checked_store_ids).order(:date)
    @date_sales_amount = @analyses.group(:date).sum(:ex_tax_sales_amount)
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

    date = @analysis.store_daily_menu.start_time
    store_id = @analysis.store_daily_menu.store_id
    @store_daily_menu = @analysis.store_daily_menu
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
    @analysis = Analysis.new()
  end

  def edit
  end

  def create
    store_daily_menu_id = params["analysis"]["store_daily_menu_id"]
    store_daily_menu = StoreDailyMenu.find(store_daily_menu_id)
    @analysis = Analysis.new(analysis_params)
    @analysis.date = store_daily_menu.start_time
    @analysis.store_id = store_daily_menu.store_id
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
      params.require(:analysis).permit(:store_id,:date,:store_daily_menu_id)
    end
end
