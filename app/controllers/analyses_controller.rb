class AnalysesController < AdminController
  before_action :set_analysis, only: %i[ show edit update destroy ]

  def kitchen_kpi
    if params[:month].present?
      @date = "#{params[:month]}-01".to_date
      @month = params[:month]
    else
      @date = @today
      @month = "#{@date.year}-#{sprintf("%02d",@date.month)}"
    end

    if params[:to]
      @to = params[:to].to_date
    else
      @to = Date.today
    end
    if params[:from]
      @from = params[:from].to_date
    else
      @from = @to - 30
    end
    @dates =(@from..@to).to_a.reverse
    @weeks = []
    @dates.each do |date|
      @weeks << date if date.wday == 1
    end
  end
  def kpi
    if params[:month].present?
      @date = "#{params[:month]}-01".to_date
      @month = params[:month]
    else
      @date = @today
      @month = "#{@date.year}-#{sprintf("%02d",@date.month)}"
    end
    prev_month_date = @date.prev_month
    prev_year_date = @date.prev_year
    dates =(@date.beginning_of_month..@date.end_of_month).to_a
    prev_month_dates = (prev_month_date.beginning_of_month..prev_month_date.end_of_month).to_a
    prev_year_dates =(prev_year_date.beginning_of_month..prev_year_date.end_of_month).to_a

    @store_daily_menus = StoreDailyMenu.where(start_time:dates)
    prev_month_store_daily_menus = StoreDailyMenu.where(start_time:prev_month_dates)
    prev_year_store_daily_menus = StoreDailyMenu.where(start_time:prev_year_dates)
    
    @foods_budgets = @store_daily_menus.group(:store_id).sum(:foods_budget)
    @goods_budgets = @store_daily_menus.group(:store_id).sum(:goods_budget)
    @prev_month_foods_budgets = prev_month_store_daily_menus.group(:store_id).sum(:foods_budget)
    @prev_month_goods_budgets = prev_month_store_daily_menus.group(:store_id).sum(:goods_budget)
    @prev_year_foods_budgets = prev_year_store_daily_menus.group(:store_id).sum(:foods_budget)
    @prev_year_goods_budgets = prev_year_store_daily_menus.group(:store_id).sum(:goods_budget)


    analyses = Analysis.where(date:dates).where('transaction_count > ?',0)
    prev_month_analyses = Analysis.where(date:prev_month_dates).where('transaction_count > ?',0)
    prev_year_analyses = Analysis.where(date:prev_year_dates).where('transaction_count > ?',0)

    @stores_count = analyses.group(:store_id).count
    prev_month_stores_count = prev_month_analyses.group(:store_id).count
    prev_year_stores_count = prev_year_analyses.group(:store_id).count

    @store_bumon_sales = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @prev_month_store_bumon_sales = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @prev_year_store_bumon_sales = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    
    [:sozai,:bento,:other,:vege,:good].each do |category|
      @store_bumon_sales[category][:total] = 0
      @prev_month_store_bumon_sales[category][:total] = 0
      @prev_year_store_bumon_sales[category][:total] = 0
    end

    store_sales = AnalysisCategory.where(analysis_id:analyses.ids).joins(:analysis).group('analyses.store_id').group(:smaregi_bumon_id).sum(:ex_tax_sales_amount)
    prev_month_store_sales = AnalysisCategory.where(analysis_id:prev_month_analyses.ids).joins(:analysis).group('analyses.store_id').group(:smaregi_bumon_id).sum(:ex_tax_sales_amount)
    prev_year_store_sales = AnalysisCategory.where(analysis_id:prev_year_analyses.ids).joins(:analysis).group('analyses.store_id').group(:smaregi_bumon_id).sum(:ex_tax_sales_amount)

    store_sales.keys.map{|store_bumon|store_bumon[0]}.uniq.each do |store_id|
      [:sozai,:bento,:other,:vege,:good].each do |category|
        @store_bumon_sales[category][:stores][store_id][:amount] = 0
      end
    end

    prev_month_store_sales.keys.map{|store_bumon|store_bumon[0]}.uniq.each do |store_id|
      [:sozai,:bento,:other,:vege,:good].each do |category|
        @prev_month_store_bumon_sales[category][:stores][store_id][:amount] = 0
      end
    end

    prev_year_store_sales.keys.map{|store_bumon|store_bumon[0]}.uniq.each do |store_id|
      [:sozai,:bento,:other,:vege,:good].each do |category|
        @prev_year_store_bumon_sales[category][:stores][store_id][:amount] = 0
      end
    end

    @store_chakuchi = {}
    @prev_month_store_chakuchi = {}
    @prev_year_store_chakuchi = {}
    @store_date_count = @store_daily_menus.where("foods_budget > ?",0).group(:store_id).count
    test(store_sales,@store_bumon_sales,@store_chakuchi,@stores_count,@store_date_count)
    test(prev_month_store_sales,@prev_month_store_bumon_sales,@prev_month_store_chakuchi,prev_month_stores_count,@store_date_count)
    test(prev_year_store_sales,@prev_year_store_bumon_sales,@prev_year_store_chakuchi,prev_year_stores_count,@store_date_count)
    if params[:to]
      @to = params[:to].to_date
    else
      @to = Date.today
    end
    if params[:from]
      @from = params[:from].to_date
    else
      @from = @to - 30
    end
    @dates =(@from..@to).to_a
    @analyses = Analysis.where(date:@dates).where('transaction_count > ?',0)
    @days = @dates.count
    @stores = current_user.group.stores.where(store_type:0)
    @store_analyses = @analyses.includes(:store_daily_menu).map{|analysis|[[analysis.store_daily_menu.start_time,analysis.store_daily_menu.store_id],analysis]}.to_h
    @date_analyses = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @date_store_analyses = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @analyses.each do |analysis|
      @date_store_analyses[analysis.date][analysis.store_id][:sales_amount] = analysis.ex_tax_sales_amount
      @date_store_analyses[analysis.date][analysis.store_id][:discount_amount] = analysis.discount_amount
      @date_store_analyses[analysis.date][analysis.store_id][:loss_amount] = analysis.loss_amount
      @date_store_analyses[analysis.date][analysis.store_id][:transaction_count] = analysis.transaction_count
      @date_store_analyses[analysis.date][analysis.store_id][:sales_number] = analysis.total_sozai_sales_number
      @date_store_analyses[analysis.date][analysis.store_id][:souzai_sales_amount] = analysis.analysis_categories.where(smaregi_bumon_id:[1,8]).sum(:ex_tax_sales_amount)
    end
    @date_sales = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    AnalysisCategory.includes(:analysis).where(analysis_id:@analyses.ids).each do |ac|
      if [14,15,16,17,18].include?(ac.smaregi_bumon_id)
        if @date_sales[ac.analysis.store_id][ac.analysis.date][:good].present?
          @date_sales[ac.analysis.store_id][ac.analysis.date][:good] += ac.ex_tax_sales_amount
        else
          @date_sales[ac.analysis.store_id][ac.analysis.date][:good] = ac.ex_tax_sales_amount
        end
      else
        if @date_sales[ac.analysis.store_id][ac.analysis.date][:souzai].present?
          @date_sales[ac.analysis.store_id][ac.analysis.date][:souzai] += ac.ex_tax_sales_amount
        else
          @date_sales[ac.analysis.store_id][ac.analysis.date][:souzai] = ac.ex_tax_sales_amount
        end
      end
    end
    souzai_datas = []
    souzai_uriage_datas = []
    colors = ['#46B061','#FBC527','#4F8DF5','#E64C3F','#FD7610']
    if params[:last_to]
      @last_to =  params[:last_to]
    else
      @last_to =  @from - 1
    end
    if params[:last_from]
      @last_from =  params[:last_from]
    else
      @last_from = @last_to - @days
    end
    last_period = (@last_from..@last_to)
    last_analyses = Analysis.where(date:last_period).where('transaction_count > ?',0)
    last_average_sales_datas = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    last_analyses.each do |analysis|
      if last_average_sales_datas[analysis.store_id][analysis.date.wday].present?
        # last_average_sales_datas[analysis.store_id][analysis.date.wday][:souzai_sales_number] += analysis.total_sozai_sales_number
        last_average_sales_datas[analysis.store_id][analysis.date.wday][:souzai_sales_amount] += analysis.analysis_categories.where(smaregi_bumon_id:[1,8]).sum(:ex_tax_sales_amount)
        last_average_sales_datas[analysis.store_id][analysis.date.wday][:count] += 1
      else
        # last_average_sales_datas[analysis.store_id][analysis.date.wday][:souzai_sales_number] = analysis.total_sozai_sales_number
        last_average_sales_datas[analysis.store_id][analysis.date.wday][:souzai_sales_amount] = analysis.analysis_categories.where(smaregi_bumon_id:[1,8]).sum(:ex_tax_sales_amount)
        last_average_sales_datas[analysis.store_id][analysis.date.wday][:count] = 1
      end
    end
    last_average_sales_datas.each do |data|
      data[1].each do |data_more|
        # last_average_sales_datas[data[0]][data_more[0]][:average] = (data_more[1][:souzai_sales_number].to_f/data_more[1][:count]).round(2)
        last_average_sales_datas[data[0]][data_more[0]][:average_sales] = (data_more[1][:souzai_sales_amount].to_f/data_more[1][:count]).round(2)
      end
    end
    @stores.each_with_index do |store,i|
      souzai_uriage_data = []
      @dates.sort.each do |date|
        if @date_store_analyses[date][store.id].present?
          if last_average_sales_datas[store.id][date.wday].present?
            souzai_uriage_data << (@date_store_analyses[date][store.id][:souzai_sales_amount]/last_average_sales_datas[store.id][date.wday][:average_sales]*100).round
          end
        else
          @date_store_analyses[date].delete(store.id)
        end
      end
    end

    @weekly_clean_reminder_templates = ReminderTemplate.where(category:1,repeat_type:11)
    @monthly_clean_reminder_templates = ReminderTemplate.where(category:1,repeat_type:12)
    @weekly_clean_reminders = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @monthly_clean_reminders = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @reminders_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @period_reminders_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @weekly_clean_dates = []
    Reminder.where(reminder_template_id:@weekly_clean_reminder_templates.ids,action_date:@dates,category:1).each do |reminder|
      if @weekly_clean_reminders[reminder.store_id][reminder.action_date][reminder.status].present?
        @weekly_clean_reminders[reminder.store_id][reminder.action_date][reminder.status] += 1
      else
        @weekly_clean_reminders[reminder.store_id][reminder.action_date][reminder.status] = 1
      end
      if @weekly_clean_reminders[reminder.store_id][reminder.action_date][:all].present?
        @weekly_clean_reminders[reminder.store_id][reminder.action_date][:all] += 1
      else
        @weekly_clean_reminders[reminder.store_id][reminder.action_date][:all] = 1
      end
      @weekly_clean_dates << reminder.action_date
    end
    @weekly_clean_dates = @weekly_clean_dates.uniq.sort
    Reminder.where(reminder_template_id:@monthly_clean_reminder_templates.ids,action_date:dates,category:1).each do |reminder|
      if @monthly_clean_reminders[reminder.store_id][reminder.status].present?
        @monthly_clean_reminders[reminder.store_id][reminder.status] += 1
      else
        @monthly_clean_reminders[reminder.store_id][reminder.status] = 1
      end
      if @monthly_clean_reminders[reminder.store_id][:all].present?
        @monthly_clean_reminders[reminder.store_id][:all] += 1
      else
        @monthly_clean_reminders[reminder.store_id][:all] = 1
      end
    end

    Reminder.where(action_date:dates,category:0).each do |reminder|
      if @reminders_hash[reminder.store_id][:monthly][reminder.status].present?
        @reminders_hash[reminder.store_id][:monthly][reminder.status] += 1
      else
        @reminders_hash[reminder.store_id][:monthly][reminder.status] = 1
      end
      if @reminders_hash[reminder.store_id][reminder.action_date][reminder.status].present?
        @reminders_hash[reminder.store_id][reminder.action_date][reminder.status] += 1
      else
        @reminders_hash[reminder.store_id][reminder.action_date][reminder.status] = 1
      end
      if @reminders_hash[reminder.store_id][:monthly][:all].present?
        @reminders_hash[reminder.store_id][:monthly][:all] += 1
      else
        @reminders_hash[reminder.store_id][:monthly][:all] = 1
      end
      if @reminders_hash[reminder.store_id][reminder.action_date][:all].present?
        @reminders_hash[reminder.store_id][reminder.action_date][:all] += 1
      else
        @reminders_hash[reminder.store_id][reminder.action_date][:all] = 1
      end
    end
    Reminder.where(action_date:@dates,category:0).each do |reminder|
      if @period_reminders_hash[reminder.store_id][:monthly][reminder.status].present?
        @period_reminders_hash[reminder.store_id][:monthly][reminder.status] += 1
      else
        @period_reminders_hash[reminder.store_id][:monthly][reminder.status] = 1
      end
      if @period_reminders_hash[reminder.store_id][reminder.action_date][reminder.status].present?
        @period_reminders_hash[reminder.store_id][reminder.action_date][reminder.status] += 1
      else
        @period_reminders_hash[reminder.store_id][reminder.action_date][reminder.status] = 1
      end

      if reminder.important_status.present?
        if @period_reminders_hash[reminder.store_id][reminder.action_date][:important_status][reminder.important_status].present?
          @period_reminders_hash[reminder.store_id][reminder.action_date][:important_status][reminder.important_status] += 1
        else
          @period_reminders_hash[reminder.store_id][reminder.action_date][:important_status][reminder.important_status] = 1
        end
      end

      if @period_reminders_hash[reminder.store_id][:monthly][:all].present?
        @period_reminders_hash[reminder.store_id][:monthly][:all] += 1
      else
        @period_reminders_hash[reminder.store_id][:monthly][:all] = 1
      end
      if @period_reminders_hash[reminder.store_id][reminder.action_date][:all].present?
        @period_reminders_hash[reminder.store_id][reminder.action_date][:all] += 1
      else
        @period_reminders_hash[reminder.store_id][reminder.action_date][:all] = 1
      end
    end

    @shifts = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    Shift.includes(:staff).where(date:@dates,fix_shift_pattern_id:254).each do |shift|
      if shift.present?
        @shifts[shift.store_id][shift.date] = shift.staff.short_name
      else
        @shifts[shift.store_id][shift.date] = ""
      end
    end

    @kaiin_datas = SmaregiMember.where(nyukaibi:@dates).group(:main_use_store,:nyukaibi).count
    @stores_henkan = {"9"=>"higashi_nakano","19"=>"shin_nakano","29"=>'shinkoenji',"154"=>"numabukuro","164"=>"ogikubo"}


    @daily_items = DailyItem.where(date:dates,purpose:"物販")
    @category_sum = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @buppan_sum = {"estimated_sales_sum"=>0,"subtotal_price_sum"=>0,"arari_sum"=>0,"purchase_price_sum"=>0,"delivery_fee_sum"=>0}
    ["野菜","果実","物産品","送料"].each do |category|
      item_varieties = ItemVariety.joins(:item_type).where(:item_types => {category:category})
      items = Item.where(item_variety_id:item_varieties.ids)
      daily_items = @daily_items.where(item_id:items.ids)
      subtotal_price_sum = daily_items.sum(:subtotal_price)
      delivery_fee_sum = daily_items.sum(:delivery_fee)
      purchase_price_sum = daily_items.map{|di|di.purchase_price * di.delivery_amount}.sum
      estimated_sales = daily_items.sum(:estimated_sales)
      arari = estimated_sales - subtotal_price_sum
      @buppan_sum["estimated_sales_sum"] += estimated_sales
      @buppan_sum["subtotal_price_sum"] += subtotal_price_sum
      @buppan_sum["purchase_price_sum"] += purchase_price_sum
      @buppan_sum["delivery_fee_sum"] += delivery_fee_sum
      @buppan_sum["arari_sum"] += arari
      @category_sum[category]["estimated_sales_sum"] = estimated_sales
      @category_sum[category]["purchase_price_sum"] = purchase_price_sum
      @category_sum[category]["delivery_fee_sum"] = delivery_fee_sum
      @category_sum[category]["subtotal_price_sum"] = subtotal_price_sum
      @category_sum[category]["arari_sum"] = arari
      @category_sum[category]["arari_rate"] = (arari/estimated_sales.to_f*100).round(1) if estimated_sales > 0
    end
    sales_reports = SalesReport.where(date:@dates)
    @sales_reports = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    sales_reports.each do |sr|
      @sales_reports[sr.date][sr.store_id][:opot] = sr.one_pair_one_talk
      @sales_reports[sr.date][sr.store_id][:tasting] = sr.tasting_number
    end

    @group = Group.find(9)
    store_ids = @group.stores.where(store_type:'sales').ids
    @fix_shift_patterns = FixShiftPattern.where(group_id:@group.id)
    StaffStore.where(store_id:store_ids)
    @staffs = Staff.joins(:staff_stores).where(status:0,:staff_stores => {store_id:store_ids}).order(:row).uniq
    @jobcounts = Shift.where(date:@from..@to).joins(:fix_shift_pattern).where.not(:fix_shift_patterns => {working_hour:0}).group(:staff_id).count
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

    
    @sales_report_staffs = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    SalesReportStaff.where(sales_report_id:sales_reports.ids).each do |srs|
      @sales_report_staffs[srs.staff_id][srs.sales_report.date][:sales_report] = srs.sales_report
      @sales_report_staffs[srs.staff_id][srs.sales_report.date][:smile] = srs.smile
      @sales_report_staffs[srs.staff_id][srs.sales_report.date][:eyecontact] = srs.eyecontact
      @sales_report_staffs[srs.staff_id][srs.sales_report.date][:voice_volume] = srs.voice_volume
    end
  end
  def bumon_sales
    @to = Date.today
    @from = @to - 30
    @from = params[:from].to_date if params[:from]
    @to = params[:to].to_date if params[:to]
    @dates =(@from..@to).to_a
    @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @bumon = {"1"=>"惣菜","2"=>"ご飯・丼","3"=>"ドリ・デザ","4"=>"備品","5"=>"お弁当","6"=>"オードブル","7"=>"スープ","8"=>"惣菜（仕入れ）","9"=>"レジ修正","11"=>"オプション","13"=>"デリバリー商品","14"=>"野菜","15"=>"物産","16"=>"予約ギフト","17"=>"野菜","18"=>"果実","0"=>"他"}
    if params[:store_id].present?
      @store = Store.find(params[:store_id])
      @pattern = params[:pattern]
      @analyses = Analysis.where(date:@dates).where(store_id:@store.id).order(:date)
      AnalysisCategory.where(analysis_id:@analyses.ids).each do |ac|
        @hash[ac.analysis_id][ac.smaregi_bumon_id.to_i] = ac
      end
    else
      @stores = current_user.group.stores
      @pattern = params[:pattern]
      @analyses = Analysis.where(date:@dates).where(store_id:@stores.ids).order(:date)
      AnalysisCategory.where(analysis_id:@analyses.ids).each do |ac|
        @hash[ac.analysis_id][ac.smaregi_bumon_id.to_i] = ac
      end
    end

    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "analysis_category.csv", type: :csv
      end
    end
  end
  def loss
    @stores = Store.where(group_id:current_user.group_id,store_type:'sales')
    if params[:stores]
      checked_store_ids = params['stores'].keys
    else
      checked_store_ids = @stores.ids
      params[:stores] = {}
      @stores.each do |store|
        params[:stores][store.id.to_s] = true
      end
    end
    @stores = Store.where(id:checked_store_ids)
    @smaregi_store_ids = @stores.map{|store|store.smaregi_store_id}

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
    @date_discount_amount = @analyses.group(:date).sum(:discount_amount)
    
    uchikeshi_torihiki_ids = SmaregiTradingHistory.where(date:params[:from]..params[:to]).where(uchikeshi_kubun:2,tenpo_id:@smaregi_store_ids).map{|sth|sth.uchikeshi_torihiki_id}.uniq
    smaregi_trading_histories = SmaregiTradingHistory.where(date:params[:from]..params[:to]).where(torihiki_meisaikubun:1,tenpo_id:@smaregi_store_ids).where.not(torihiki_id:uchikeshi_torihiki_ids)
    
    @staff_off = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @kaiin_toroku_off = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @other_off = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @point_off = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    shokei_nebiki_smaregi_trading_histories = smaregi_trading_histories.where("shokei_nebiki > ?",0)
    shokei_nebiki_smaregi_trading_histories.each do |snsth|
      if snsth.shokei_nebiki_kubun == "社割"
        @staff_off[snsth.date][snsth.torihiki_id] = snsth.shokei_nebiki 
      elsif snsth.shokei_nebiki_kubun == "会員登録"
        @kaiin_toroku_off[snsth.date][snsth.torihiki_id] = snsth.shokei_nebiki
      else
        @other_off[snsth.date][snsth.torihiki_id] = snsth.shokei_nebiki
      end
    end

    smaregi_trading_histories.where("point_nebiki > ?",0).each do |sth|
      @point_off[sth.date][sth.torihiki_id] = sth.point_nebiki
    end
    @ten_per_off = smaregi_trading_histories.where(tanpin_waribiki:10).group(:date).sum(:tanka_nebikikei)
    @twenty_per_off = smaregi_trading_histories.where(tanpin_waribiki:20).group(:date).sum(:tanka_nebikikei)
    @thirty_per_off = smaregi_trading_histories.where(tanpin_waribiki:30).group(:date).sum(:tanka_nebikikei)
    @fifty_per_off = smaregi_trading_histories.where(tanpin_waribiki:50).group(:date).sum(:tanka_nebikikei)
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "loss_#{@from}_#{@to}.csv", type: :csv
      end
    end    
  end
  def monthly_timezone
    @weekdays = %w[月 火 水 木 金 土 日]
    @weekdays_index = ['2','3','4','5','6','7','1']
    if params[:weekdays].present?
      @weekdays_index = params[:weekdays]
    end
    @stores = Store.where(group_id:current_user.group_id)
    if params[:stores]
      checked_store_ids = params['stores'].keys
    else
      checked_store_ids = @stores.ids
      params[:stores] = {}
      @stores.each do |store|
        params[:stores][store.id.to_s] = true
      end
    end
    stores = Store.where(id:checked_store_ids)
    smaregi_store_ids = stores.map{|store|store.smaregi_store_id}
    if params[:to]
      params[:to] = params[:to].to_date
    else
      params[:to] = Date.today
    end
    if params[:from]
      params[:from] = params[:from].to_date
    else
      params[:from] = params[:to] - 365
    end
    @months = (params[:from]..params[:to]).map{|date|"#{date.year}-#{date.strftime('%m')}"}.uniq
    smaregi_trading_histories = SmaregiTradingHistory.where(date:params[:from]..params[:to]).search_by_week(@weekdays_index)
    uchikeshi_torihiki_ids = smaregi_trading_histories.where(uchikeshi_kubun:2,tenpo_id:smaregi_store_ids).map{|sth|sth.uchikeshi_torihiki_id}.uniq
    smaregi_trading_histories = smaregi_trading_histories.where(torihiki_meisaikubun:1,tenpo_id:smaregi_store_ids).where.not(torihiki_id:uchikeshi_torihiki_ids)
    @date_count = smaregi_trading_histories.group("date_format(date, '%Y-%m')").count('DISTINCT analysis_id')
    @time_zone_sales = smaregi_trading_histories.group("date_format(date, '%Y-%m')").group("date_format(time, '%H')").sum(:zeinuki_uriage)
    @time_zone_counts = smaregi_trading_histories.group("date_format(date, '%Y-%m')").group("date_format(time, '%H')").distinct.count(:torihiki_id)
    @time_zone_sales_product = smaregi_trading_histories.group("date_format(date, '%Y-%m')").group("date_format(time, '%H')").group(:bumon_id).sum(:suryo)
    @time_zone_nebikigaku_gokei = smaregi_trading_histories.group("date_format(date, '%Y-%m')").group("date_format(time, '%H')").sum(:tanka_nebikikei)
    @time_zone_nebikisu_gokei = smaregi_trading_histories.where("tanka_nebikikei >0").group("date_format(date, '%Y-%m')").group("date_format(time, '%H')").sum(:suryo)

  end
  def reload_product_repeat
    SmaregiMemberProduct.calculate_number
    redirect_to product_repeat_analyses_path,notice:'更新しました'
  end
  def product_repeat
    product_ids = SmaregiMemberProduct.all.map{|smp|smp.product_id}.uniq
    @products = Product.where(id:product_ids)
    # 16時までの販売データ
    @hash = SmaregiMemberProduct.all.group(:product_id,:early_number_of_purchase).count
    daily_menu_ids = DailyMenu.where(start_time:"2023-01-01".to_date..(Date.today-1)).ids
    @product_count = DailyMenuDetail.where(daily_menu_id:daily_menu_ids).group(:product_id).count
    @uu = SmaregiMemberProduct.where.not(early_number_of_purchase:0).group(:product_id).count
    @repeat_count = SmaregiMemberProduct.where("early_number_of_purchase > ?",1).group(:product_id).count
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "repeat_products.csv", type: :csv
      end
    end
  end
  def ltv_data
    store_id = params[:store_id]
    year = params[:year].to_i
    month = params[:month].to_i
    if store_id.present? && year.present? && month.present?
      store = Store.find(store_id)
      smaregi_trading_histories = SmaregiTradingHistory.where(date:Date.new(year,month,1).all_month).where(tenpo_id:store.smaregi_store_id).where.not(kaiin_id:nil)
      uchikeshi_torihiki_ids = smaregi_trading_histories.where(torihiki_meisaikubun:2).map{|sth|sth.uchikeshi_torihiki_id}.uniq
      @smaregi_trading_histories = smaregi_trading_histories.where.not(torihiki_id:uchikeshi_torihiki_ids).where(torihiki_meisaikubun:1)
      @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
      kaiin_ids = @smaregi_trading_histories.map{|sth|sth.kaiin_id}
      @kaiin_nyukai_date =SmaregiMember.where(kaiin_id:kaiin_ids).map{|sm|[sm.kaiin_id,sm.nyukaibi]}.to_h
      @smaregi_trading_histories.each do |sth|
        if @hash[sth.torihiki_id].present?
        else
          @hash[sth.torihiki_id][:date] = sth.date
          @hash[sth.torihiki_id][:gokei] = sth.gokei
          @hash[sth.torihiki_id][:suryo_gokei] = sth.suryo_gokei
          @hash[sth.torihiki_id][:tenpo_id] = sth.tenpo_id
          @hash[sth.torihiki_id][:kaiin_id] = sth.kaiin_id
          @hash[sth.torihiki_id][:kaiin_code] = sth.kaiin_code
          @hash[sth.torihiki_id][:hanbaiin_id] = sth.hanbaiin_id
          @hash[sth.torihiki_id][:time] = sth.time.strftime('%H:%M')
          @hash[sth.torihiki_id][:receipt_number] = sth.receipt_number
          @hash[sth.torihiki_id][:nyukaibi] = @kaiin_nyukai_date[sth.kaiin_id]
        end
      end
    else
      @hash = []
    end
    respond_to do |format|
      format.html do
        @hash = Kaminari.paginate_array(@hash.to_a).page(params[:page]).per(50)
      end
      format.csv do
        send_data render_to_string, filename: "#{store_id}_#{year}-#{month}_ltv.csv", type: :csv
      end
    end
  end
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
    @stores = Store.where(group_id:current_user.group_id)
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
    @staffs = WorkingHour.where(date:@dates,group_id:current_user.group_id).pluck(:name).uniq
    WorkingHour.where(date:@dates,group_id:current_user.group_id).each do |wh|
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
      @stores = Store.where(group_id:current_user.group_id)
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
    @dates = (@from..@to).to_a.reverse
    @group = Group.find(9)
    store_ids = @group.stores.where(store_type:'sales').ids
    @fix_shift_patterns = FixShiftPattern.where(group_id:@group.id)
    StaffStore.where(store_id:store_ids)
    @staffs = Staff.joins(:staff_stores).where(status:0,:staff_stores => {store_id:store_ids}).order(:row).uniq
    @jobcounts = Shift.where(date:@from..@to).joins(:fix_shift_pattern).where.not(:fix_shift_patterns => {working_hour:0}).group(:staff_id).count
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

    sales_report_ids = SalesReport.where(date:@dates)
    @sales_report_staffs = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    SalesReportStaff.where(sales_report_id:sales_report_ids).each do |srs|
      @sales_report_staffs[srs.staff_id][srs.sales_report.date][:sales_report] = srs.sales_report
      @sales_report_staffs[srs.staff_id][srs.sales_report.date][:smile] = srs.smile
      @sales_report_staffs[srs.staff_id][srs.sales_report.date][:eyecontact] = srs.eyecontact
      @sales_report_staffs[srs.staff_id][srs.sales_report.date][:voice_volume] = srs.voice_volume
    end
  end
  def stores
    if params[:date].present?
      @date = params[:date].to_date
    else
      @date = Date.today
    end
    @stores = Store.where(group_id:current_user.group_id)
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
    @sales_hash = {goods:0,foods:0}
    @discount_hash = {goods:0,foods:0}
    @store = Store.find(params[:store_id])
    if params[:date].present?
      @date = params[:date].to_date
    else
      @date = Date.today
    end
    @dates =(Date.new(2024,8,1)..@date.end_of_month).to_a
    @analyses = Analysis.where(date:@dates).where(store_id:@store.id).order(:date)
    @date_analyses = @analyses.map{|analysis|[analysis.date,analysis]}.to_h
    @date_analysis_categories = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @analyses.each do |analysis|
      @date_analysis_categories[analysis.date][:foods][:ex_tax_sales_amount] = 0
      @date_analysis_categories[analysis.date][:foods][:discount_amount] = 0
      @date_analysis_categories[analysis.date][:foods][:sales_number] = 0
      @date_analysis_categories[analysis.date][:veges][:ex_tax_sales_amount] = 0
      @date_analysis_categories[analysis.date][:veges][:discount_amount] = 0
      @date_analysis_categories[analysis.date][:veges][:sales_number] = 0
      @date_analysis_categories[analysis.date][:goods][:ex_tax_sales_amount] = 0
      @date_analysis_categories[analysis.date][:goods][:discount_amount] = 0
      @date_analysis_categories[analysis.date][:goods][:sales_number] = 0
      analysis.analysis_categories.each do |ac|
        if [14,15,16,17,18].include?(ac.smaregi_bumon_id)
          @date_analysis_categories[analysis.date][:goods][:ex_tax_sales_amount] += ac.ex_tax_sales_amount
          @date_analysis_categories[analysis.date][:goods][:discount_amount] += ac.discount_amount
          @date_analysis_categories[analysis.date][:goods][:sales_number] += ac.sales_number
          @sales_hash[:goods] += ac.ex_tax_sales_amount
          @discount_hash[:goods] += ac.discount_amount
        else
          @date_analysis_categories[analysis.date][:foods][:ex_tax_sales_amount] += ac.ex_tax_sales_amount
          @date_analysis_categories[analysis.date][:foods][:discount_amount] += ac.discount_amount
          @date_analysis_categories[analysis.date][:foods][:sales_number] += ac.sales_number
          @sales_hash[:foods] += ac.ex_tax_sales_amount
          @discount_hash[:foods] += ac.discount_amount
        end
      end
    end
    @date_sales_amount = @analyses.group(:date).sum(:ex_tax_sales_amount)
    @date_loss_amount = @analyses.group(:date).sum(:loss_amount)
    @date_transaction_count = @analyses.group(:date).sum(:transaction_count)

    @business_day_num = @date.end_of_month.day
    @store_daily_menus = StoreDailyMenu.where(start_time:@dates,store_id:@store.id)
    @date_store_daily_menus = @store_daily_menus.map{|sdm|[sdm.start_time,sdm]}.to_h
    @foods_total_budget = 0
    @goods_total_budget = 0
    @budget_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @store_daily_menus.each do |sdm|
      @budget_hash[sdm.start_time][:foods] = sdm.foods_budget.to_i
      @budget_hash[sdm.start_time][:goods] = sdm.goods_budget.to_i
      @budget_hash[sdm.start_time][:date] = sdm.foods_budget.to_i + sdm.goods_budget.to_i
      @foods_total_budget += sdm.foods_budget.to_i
      @goods_total_budget += sdm.goods_budget.to_i
    end
    @total_budget = @foods_total_budget+@goods_total_budget
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
    if params[:month].present?
      @date = "#{params[:month]}-01".to_date
      @month = params[:month]
    else
      @date = @today
      @month = "#{@date.year}-#{sprintf("%02d",@date.month)}"
    end
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
      @stores = Store.where(group_id:current_user.group_id,store_type:'sales')
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

  def vegetable_time_sales
    @stores = Store.where(group_id:current_user.group_id)
    if params[:stores]
      checked_store_ids = params['stores'].keys
    else
      checked_store_ids = @stores.ids
      params[:stores] = {}
      @stores.each do |store|
        params[:stores][store.id.to_s] = true
      end
    end
    if params[:from]
      @from = params[:from].to_date
    else
      @from = Date.today.prev_occurring(:wednesday)
      params[:from] = @from
    end
    if params[:to]
      @to = params[:to].to_date
    else
      @to = @from + 6
      params[:to] = @to
    end
    @dates = (@from..@to)
    @times = (10..21)
    @smaregi_trading_histories = SmaregiTradingHistory.joins(:analysis).where(:analyses=>{store_id:checked_store_ids,date:@dates}).where(bumon_id:14)
    @uniq_shohin_ids =[]
    @sales_data = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @time_data = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @smaregi_trading_histories.each do |sth|
      @uniq_shohin_ids << sth.shohin_id unless @uniq_shohin_ids.include?(sth.shohin_id)
      if sth.torihiki_meisaikubun == 1 || sth.torihiki_meisaikubun == 3
        suryo = sth.suryo
        amount = sth.nebikigokei
      elsif sth.torihiki_meisaikubun == 2
        suryo = -sth.suryo
        amount = -sth.nebikigokei
      end

      @sales_data[sth.shohin_id][:name] = sth.shohinmei unless @sales_data[sth.shohin_id].present?

      if @sales_data[sth.shohin_id][:time][sth.time.hour].present?
        @sales_data[sth.shohin_id][:time][sth.time.hour][:sales_num] += suryo
        @sales_data[sth.shohin_id][:time][sth.time.hour][:sales_amount] += amount
      else
        @sales_data[sth.shohin_id][:time][sth.time.hour][:sales_num] = suryo
        @sales_data[sth.shohin_id][:time][sth.time.hour][:sales_amount] = amount
      end
      if @sales_data[sth.shohin_id][:sales_amount].present?
        @sales_data[sth.shohin_id][:sales_amount] += amount
      else
        @sales_data[sth.shohin_id][:sales_amount] = amount
      end
      if @sales_data[sth.shohin_id][:sales_num].present?
        @sales_data[sth.shohin_id][:sales_num] += suryo
      else
        @sales_data[sth.shohin_id][:sales_num] = suryo
      end
      if @time_data[sth.time.hour].present?
        @time_data[sth.time.hour][:num] += suryo
        @time_data[sth.time.hour][:amount] += amount
      else
        @time_data[sth.time.hour][:num] = suryo
        @time_data[sth.time.hour][:amount] = amount
      end
    end
    gon.times = @times.to_a
    gon.sales_num_data = []
    gon.sales_amount_data = []
    @times.each do |time|
      if @time_data[time]
        gon.sales_num_data << @time_data[time][:num]
        gon.sales_amount_data << @time_data[time][:amount]
      else
        gon.sales_num_data << 0
        gon.sales_amount_data << 0
      end
    end
  end



  def vegetable_sales
    @stores = Store.where(group_id:current_user.group_id)
    if params[:stores]
      checked_store_ids = params['stores'].keys
    else
      checked_store_ids = @stores.ids
      params[:stores] = {}
      @stores.each do |store|
        params[:stores][store.id.to_s] = true
      end
    end
    if params[:from]
      @from = params[:from].to_date
    else
      @from = Date.today.prev_occurring(:wednesday)
      params[:from] = @from
    end
    if params[:to]
      @to = params[:to].to_date
    else
      @to = @from + 6
      params[:to] = @to
    end
    @dates = (@from..@to)
    @smaregi_trading_histories = SmaregiTradingHistory.joins(:analysis).where(:analyses=>{store_id:checked_store_ids,date:@dates}).where(bumon_id:14)
    @uniq_shohin_ids =[]
    @sales_data = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @wday_data = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @smaregi_trading_histories.each do |sth|
      @uniq_shohin_ids << sth.shohin_id unless @uniq_shohin_ids.include?(sth.shohin_id)
      if sth.torihiki_meisaikubun == 1 || sth.torihiki_meisaikubun == 3
        suryo = sth.suryo
        amount = sth.nebikigokei
      elsif sth.torihiki_meisaikubun == 2
        suryo = -sth.suryo
        amount = -sth.nebikigokei
      end

      @sales_data[sth.shohin_id][:name] = sth.shohinmei unless @sales_data[sth.shohin_id].present?

      if @sales_data[sth.shohin_id][:date][sth.date].present?
        @sales_data[sth.shohin_id][:date][sth.date][:sales_num] += suryo
        @sales_data[sth.shohin_id][:date][sth.date][:sales_amount] += amount
      else
        @sales_data[sth.shohin_id][:date][sth.date][:sales_num] = suryo
        @sales_data[sth.shohin_id][:date][sth.date][:sales_amount] = amount
      end

      if @sales_data[sth.shohin_id][:sales_amount].present?
        @sales_data[sth.shohin_id][:sales_amount] += amount
      else
        @sales_data[sth.shohin_id][:sales_amount] = amount
      end
      if @sales_data[sth.shohin_id][:sales_num].present?
        @sales_data[sth.shohin_id][:sales_num] += suryo
      else
        @sales_data[sth.shohin_id][:sales_num] = suryo
      end
      if @wday_data[sth.date.wday].present?
        @wday_data[sth.date.wday][:num] += suryo
        @wday_data[sth.date.wday][:amount] += amount
      else
        @wday_data[sth.date.wday][:num] = suryo
        @wday_data[sth.date.wday][:amount] = amount
      end
    end
    wdays = [1,2,3,4,5,6,0]
    gon.wdays = ["月","火","水","木","金","土","日"]
    gon.sales_num_data = []
    gon.sales_amount_data = []
    wdays.each do |wday|
      if @wday_data[wday]
        gon.sales_num_data << @wday_data[wday][:num]
        gon.sales_amount_data << @wday_data[wday][:amount]
      else
        gon.sales_num_data << 0
        gon.sales_amount_data << 0
      end
    end
  end


  def product_sales
    @stores = Store.where(group_id:current_user.group_id)
    if params[:stores]
      checked_store_ids = params['stores'].keys
    else
      checked_store_ids = @stores.ids
      params[:stores] = {}
      @stores.each do |store|
        params[:stores][store.id.to_s] = true
      end
    end
    if params[:from]
      @from = params[:from].to_date
    else
      @from = Date.today.prev_occurring(:wednesday)
      params[:from] = @from
    end
    if params[:to]
      @to = params[:to].to_date
    else
      @to = @from + 6
      params[:to] = @to
    end
    @dates = []
    if (@to - @from) < 32
      analyses = Analysis.where(date:@from..@to).where(store_id:checked_store_ids)
      @analysis_products = AnalysisProduct.includes(analysis:[:store_daily_menu]).where(analysis_id:analyses.ids)
      @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
      @product_store_sales = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
      product_ids = []
      @analysis_products.each do |ap|
        product_id = ap.product_id
        date = ap.analysis.date
        @product_store_sales[product_id][date][ap.analysis.store_id] = {list_price_sales_number:(ap.sales_number - ap.discount_number),total_sales_amount:ap.total_sales_amount,
            discount_amount:ap.discount_amount,loss_amount:ap.loss_amount,actual_inventory:ap.actual_inventory.to_i,discount_number:ap.discount_number,loss_number:ap.loss_number.to_i,
            sixteen_total_sales_number:ap.sixteen_total_sales_number,nomination_rate:ap.nomination_rate,count:1,sell_price:ap.orderecipe_sell_price,shohinmei:ap.smaregi_shohin_name,
            bumon_id:ap.bumon_id,nomination_rate:ap.nomination_rate,potential:ap.potential,sales:ap.ex_tax_sales_amount}
        if @hash[product_id][date].present?
          @hash[product_id][date][:count] += 1
          @hash[product_id][date][:actual_inventory] += ap.actual_inventory.to_i
          @hash[product_id][date][:list_price_sales_number] += (ap.sales_number - ap.discount_number)
          @hash[product_id][date][:discount_number] += ap.discount_number
          @hash[product_id][date][:total_sales_amount] += ap.total_sales_amount
          @hash[product_id][date][:discount_amount] += ap.discount_amount
          @hash[product_id][date][:loss_amount] += ap.loss_amount
          @hash[product_id][date][:loss_number] += ap.loss_number.to_i
          # 16時までに売れた個数
          @hash[product_id][date][:sixteen_total_sales_number] += ap.sixteen_total_sales_number
          @hash[product_id][date][:nomination_rate] += ap.nomination_rate
        else
          @hash[product_id][date] = {list_price_sales_number:(ap.sales_number - ap.discount_number),total_sales_amount:ap.total_sales_amount,
            discount_amount:ap.discount_amount,loss_amount:ap.loss_amount,actual_inventory:ap.actual_inventory.to_i,discount_number:ap.discount_number,loss_number:ap.loss_number.to_i,
            sixteen_total_sales_number:ap.sixteen_total_sales_number,nomination_rate:ap.nomination_rate,count:1}
          product_ids << product_id unless product_ids.include?(product_id)
          @dates << date unless @dates.include?(date)
        end
        if @hash[product_id][:period].present?
          @hash[product_id][:period][:actual_inventory] += ap.actual_inventory.to_i
          @hash[product_id][:period][:list_price_sales_number] += (ap.sales_number - ap.discount_number)
          @hash[product_id][:period][:total_sales_amount] += ap.total_sales_amount
          @hash[product_id][:period][:discount_amount] += ap.discount_amount
          @hash[product_id][:period][:discount_number] += ap.discount_number
          @hash[product_id][:period][:loss_amount] += ap.loss_amount
          @hash[product_id][:period][:loss_number] += ap.loss_number.to_i
          @hash[product_id][:period][:sixteen_total_sales_number] += ap.sixteen_total_sales_number
          @hash[product_id][:period][:nomination_rate] += ap.nomination_rate
          @hash[product_id][:period][:count] += 1
        else
          @hash[product_id][:period] = {list_price_sales_number:(ap.sales_number - ap.discount_number),total_sales_amount:ap.total_sales_amount,discount_amount:ap.discount_amount,
            loss_amount:ap.loss_amount,actual_inventory:ap.actual_inventory.to_i,discount_number:ap.discount_number,loss_number:ap.loss_number.to_i,
            sixteen_total_sales_number:ap.sixteen_total_sales_number,nomination_rate:ap.nomination_rate,count:1}
        end
      end
      @dates = @dates.sort
      @products = Product.where(id:product_ids)
    else
      redirect_to product_sales_analyses_path, danger: "期間は一ヶ月間以内にしてください。"
    end
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "商品販売データ.csv", type: :csv
      end
    end
  end

  def visitors_time_zone
    @stores = Store.where(group_id:current_user.group_id,store_type:'sales')
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
    @product_sales_potential = ProductSalesPotential.find_by(store_id:@store.id,product_id:@product.id)
    @product_sales_potential = ProductSalesPotential.create(store_id:@store.id,product_id:@product.id,sales_potential:0) unless @product_sales_potential.present?
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
        if params[:sixteen_total_sales_number_flag]=='true'
          @product_datas[ap.product_id][ap.analysis_id]['sales_number'] = ap.sixteen_total_sales_number
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
    total_sozai_sales_number = 0
    sixteen_sozai_sales_number = 0
    analysis_id = params[:analysis]["analysis_id"]
    @analysis = Analysis.find(analysis_id)
    smaregi_shohin_ids = @analysis.analysis_products.map{|ap|ap.smaregi_shohin_id}
    smaregi_trading_histories = SmaregiTradingHistory.where(analysis_id:analysis_id)
    analysis_products_arr = []
    @product_sales_number = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    product_sixteen_total_sales_number = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
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
        total_sozai_sales_number += suryo if sth.bumon_id == 1

        if sth.time.strftime('%H%M').to_i < 1400
          if product_sixteen_total_sales_number[sth.shohin_id].present?
            product_sixteen_total_sales_number[sth.shohin_id] += suryo
          else
            product_sixteen_total_sales_number[sth.shohin_id] = suryo
          end
          sixteen_sozai_sales_number += suryo if sth.bumon_id == 1
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
      if product_sixteen_total_sales_number[ap.smaregi_shohin_id].present?
        ap.sixteen_total_sales_number = product_sixteen_total_sales_number[ap.smaregi_shohin_id]
        ap.potential = ((total_sozai_sales_number.to_f/sixteen_sozai_sales_number)*product_sixteen_total_sales_number[ap.smaregi_shohin_id]).round(1)
      else
        ap.sixteen_total_sales_number = 0
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
    @stores = Store.where(group_id:current_user.group_id,store_type:'sales')
    @analyses_hash = {}
    Analysis.where(date:@date).each do |analysis|
      @analyses_hash[analysis.store_daily_menu.store_id] = analysis
    end
    @store_daily_menus_hash = StoreDailyMenu.where(start_time:@date).map{|sdm|[sdm.store_id,sdm.id]}.to_h
  end
  def summary
    @stores = Store.where(group_id:current_user.group_id,store_type:'sales')
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
    @stores = Store.where(group_id:current_user.group_id,store_type:'sales')
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
    @smaregi_trading_histories = SmaregiTradingHistory.where(analysis_id:@analysis.id)
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

  def test(store_sales,store_bumon_sales,store_chakuchi,stores_count,store_date_count)
    store_sales.each do |data|
      bumon = data[0][1]
      if  [1,8].include?(bumon.to_i)
        store_bumon_sales[:sozai][:total] += data[1]
        store_bumon_sales[:sozai][:stores][data[0][0]][:amount] += data[1]
      elsif [2,5].include?(bumon.to_i)
        store_bumon_sales[:bento][:total] += data[1]
        store_bumon_sales[:bento][:stores][data[0][0]][:amount] += data[1]
      elsif [3,4,6,7,9,11,13,0].include?(bumon.to_i)
        store_bumon_sales[:other][:total] += data[1]
        store_bumon_sales[:other][:stores][data[0][0]][:amount] += data[1]
      elsif [14,16,17,18].include?(bumon.to_i)
        store_bumon_sales[:vege][:total] += data[1]
        store_bumon_sales[:vege][:stores][data[0][0]][:amount] += data[1]
      elsif bumon.to_i == 15
        store_bumon_sales[:good][:total] += data[1]
        store_bumon_sales[:good][:stores][data[0][0]][:amount] += data[1]
      end
    end
    store_bumon_sales.each do |data|
      data[1][:stores].each do |stores_data|
        if data[1][:chakuchi].present?
          if stores_count[stores_data[0]].present?
            if store_date_count[stores_data[0]].present?
              data[1][:chakuchi] += (stores_data[1][:amount]/stores_count[stores_data[0]])*store_date_count[stores_data[0]]
            end
          end
        else
          data[1][:chakuchi] = (stores_data[1][:amount]/stores_count[stores_data[0]])*store_date_count[stores_data[0]]
        end
        if stores_count[stores_data[0]].present?
          if store_date_count[stores_data[0]].present?

            stores_data[1][:chakuchi] = (stores_data[1][:amount]/stores_count[stores_data[0]])*store_date_count[stores_data[0]]
          end
        end
      end
    end
    store_bumon_sales.values.map{|data|data[:stores]}.each do |data_more|
      data_more.each do |data_more_more|
        if store_chakuchi[data_more_more[0]].present?
          store_chakuchi[data_more_more[0]] += data_more_more[1][:chakuchi]
        else
          store_chakuchi[data_more_more[0]] = data_more_more[1][:chakuchi]
        end
      end
    end
  end

  private
    def set_analysis
      @analysis = Analysis.find(params[:id])
    end

    def analysis_params
      params.require(:analysis).permit(:store_id,:date,:store_daily_menu_id,:vegetable_waste_amount)
    end
end
