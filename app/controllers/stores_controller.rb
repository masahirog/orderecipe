class StoresController < AdminController
  before_action :set_store, only: [:show, :edit, :update, :destroy]
  def materials
    store_id = params[:store_id]
    @material_store_orderables = MaterialStoreOrderable.includes(material:[:vendor]).order('materials.vendor_id,materials.name').where(store_id:store_id,orderable_flag:true)
    @hash = {'mon'=>"2",'tue'=>"3",'wed'=>"4",'thu'=>"5",'fri'=>"6",'sat'=>"7",'sun'=>"8"}
    @wdays = {'mon'=>"月",'tue'=>"火",'wed'=>"水",'thu'=>"木",'fri'=>"金",'sat'=>"土",'sun'=>"日"}
  end
  def products
    @store = Store.find(params[:store_id])
  end
  def index
    today = Date.today
    @store_daily_menus = StoreDailyMenu.where(start_time:today).map{|sdm|[sdm.store_id,sdm]}.to_h
    @groups = Group.includes([:stores]).all
  end

  def show
    today = Date.today
    @store_daily_menu = StoreDailyMenu.find_by(start_time:today,store_id:@store.id)
    @business_day_num = today.end_of_month.day
    store_id = @store.id
    if @store_daily_menu
      @budget = @store_daily_menu.foods_budget.to_i + @store_daily_menu.vegetables_budget.to_i + @store_daily_menu.goods_budget.to_i
    end
    dates = (today.beginning_of_month..today.end_of_month).to_a
    @store_daily_menus = StoreDailyMenu.where(start_time:dates,store_id:store_id)
    @foods_total_budget = 0
    @vegetables_total_budget = 0
    @goods_total_budget = 0
    @store_daily_menus.each do |sdm|
      @foods_total_budget += sdm.foods_budget.to_i
      @vegetables_total_budget += sdm.vegetables_budget.to_i
      @goods_total_budget += sdm.goods_budget.to_i
    end
    @total_budget = @foods_total_budget+@vegetables_total_budget+@goods_total_budget
    @analyses = Analysis.where(date:dates,store_id:store_id)
    @bumon_loss_amount = [[14,0]].to_h
    analysis_categories = AnalysisCategory.where(analysis_id:@analyses.ids)
    @bumon_ex_tax_sales_amount = analysis_categories.group(:smaregi_bumon_id).sum(:ex_tax_sales_amount)
    @bumon_discount_amount = analysis_categories.group(:smaregi_bumon_id).sum(:discount_amount)

    @weekly_clean_reminder_templates = ReminderTemplate.where(category:1,repeat_type:11)
    @monthly_clean_reminder_templates = ReminderTemplate.where(category:1,repeat_type:12)
    @bow = today.beginning_of_week
    @bom = today.beginning_of_month
    @all_weekly_clean_reminders = Reminder.where(reminder_template_id:@weekly_clean_reminder_templates.ids,action_date:@bow,category:1,store_id:@store.id)
    @all_monthly_clean_reminders = Reminder.where(reminder_template_id:@monthly_clean_reminder_templates.ids,action_date:@bom,category:1,store_id:@store.id)
    @done_weekly_clean_reminders = @all_weekly_clean_reminders.where(status:1)
    @done_monthly_clean_reminders = @all_monthly_clean_reminders.where(status:1)

    @reminders = @store.reminders.where(category:0,action_date:today)
    @yet_reminders = @reminders.where(status:"yet")
    @tasks = Task.joins(:task_stores).where(:task_stores => {store_id:@store.id,subject_flag:true})
    @doings = @tasks.where(status:1)
    @checks = @tasks.where(status:2)
  end

  def new
    @store = Store.new(group_id:params[:group_id])
    ssf_ids = @store.shift_frames.ids
    @group = Group.find(params[:group_id])
    @shift_frames = @group.shift_frames
  end

  def edit
    ssf_ids = @store.shift_frames.ids
    @group = @store.group
    if current_user.group_id == @group.id
      @shift_frames = @group.shift_frames
    else
      @shift_frames = []
    end
  end

  def create
    @store = Store.new(store_params)

    respond_to do |format|
      if @store.save
        format.html { redirect_to @store, notice: 'Store was successfully created.' }
        format.json { render :show, status: :created, location: @store }
      else
        format.html { render :new }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @store.update(store_params)
        format.html { redirect_to @store, notice: 'Store was successfully updated.' }
        format.json { render :show, status: :ok, location: @store }
      else
        format.html { render :edit }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @store.destroy
    respond_to do |format|
      format.html { redirect_to _stores_url, notice: 'Store was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_store
      @store = Store.find(params[:id])
    end

    def store_params
      params.require(:store).permit(:name,:phone,:fax,:email,:zip,:address,:staff_name,:orikane_store_code,:close_flag,:short_name,
        :staff_phone,:staff_email,:memo,:jfd,:user_id,:lunch_default_shift,:dinner_default_shift,:group_id,:store_type,
      store_shift_frames_attributes:[:id,:store_id,:shift_frame_id,:default_number,:default_working_hour,:_destroy])
    end
end
