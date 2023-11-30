class RemindersController < AdminController
  before_action :set_reminder, only: %i[ show edit update destroy ]
  def clean
    if params[:date]
      @date = Date.parse(params[:date])
    else
      @date = Date.today
      params[:date]=@date
    end
    staff_ids = StaffStore.joins(:store).where(:stores => {store_type:0,group_id:current_user.group_id}).map{|ss|ss.staff_id}.uniq
    @staffs = Staff.where(id:staff_ids,status:0)
    @weekly_clean_reminder_templates = ReminderTemplate.where(category:1,repeat_type:11)
    @monthly_clean_reminder_templates = ReminderTemplate.where(category:1,repeat_type:12)
    @bow = @date.beginning_of_week
    @bom = @date.beginning_of_month
    @weekly_clean_reminders = Reminder.where(reminder_template_id:@weekly_clean_reminder_templates.ids,action_date:@bow,category:1,store_id:params[:store_id])
    @monthly_clean_reminders = Reminder.where(reminder_template_id:@monthly_clean_reminder_templates.ids,action_date:@bom,category:1,store_id:params[:store_id])
    @store = Store.find(params[:store_id])
  end
  def store
    if params[:date]
      @date = Date.parse(params[:date])
    else
      @date = Date.today
      params[:date]=@date
    end
    @store = Store.find(params[:store_id])
    @reminders = @store.reminders.where(category:0,action_date:@date).order(:action_time)
    @reminders = @reminders.where(status:params[:status]) if params[:status].present?
    @reminder = Reminder.new(store_id:params[:store_id],action_date:params[:date])
  end


  def index
    if params[:date]
      @date = Date.parse(params[:date])
    else
      @date = Date.today
      params[:date]=@date
    end
    @reminders = Reminder.where(action_date:@date)
    @reminder = Reminder.new
  end

  def show
  end

  def new
    @reminder = Reminder.new
  end

  def edit
  end

  def create
    @reminder = Reminder.new(reminder_params)
    if params['stores'].present?
      new_reminders_arr = []
      Store.where(id:params['stores'].keys).each do |store|
        new_reminder = Reminder.new(store_id:store.id,action_date:@reminder.action_date,action_time:@reminder.action_time,content:@reminder.content,memo:@reminder.memo,drafter:@reminder.drafter)
        new_reminders_arr << new_reminder
      end
      Reminder.import new_reminders_arr
    end
    respond_to do |format|
      if @reminder.save
        @store_names = [@reminder.store.name]
        if params['stores'].present?
          @store_names << Store.where(id:params['stores'].keys).pluck(:name)
        end
        message = "新規リマインダーがセットされました。\n"+
        "店舗名：#{@store_names.join('、')}\n"+
        "日付：#{@reminder.action_date.strftime('%m月 %d日')}\n"+
        "内容：#{@reminder.content}\n"+
        "メモ：#{@reminder.memo}\n"+
        "作者：#{@reminder.drafter}"
        if params['chatwork_notice'].present?
          Slack::Notifier.new("https://hooks.slack.com/services/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", username: 'Bot', icon_emoji: ':male-farmer:').ping(message)

        end
        format.html { redirect_to store_reminders_path(store_id:@reminder.store_id,date:@reminder.action_date,status:'yet'), notice: "Reminder was successfully created." }
        format.json { render :show, status: :created, location: @reminder }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @reminder.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @class_name = ".reminder_tr_#{@reminder.id}"
    @staffs = Staff.where(group_id:current_user.group_id,status:0)
    respond_to do |format|
      if @reminder.update(reminder_params)
        format.html { redirect_to store_reminders_path(store_id:@reminder.store_id,date:@reminder.action_date,status:'yet'), notice: "Reminder was successfully updated." }
        format.json { render :show, status: :ok, location: @reminder }
        format.js
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @reminder.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @reminder.destroy
    respond_to do |format|
      format.html { redirect_to reminders_url, notice: "Reminder was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_reminder
      @reminder = Reminder.find(params[:id])
    end

    def reminder_params
      params.require(:reminder).permit(:id,:store_id,:reminder_template_id,:action_date,:action_time,:content,:memo,:status,:status_change_datetime,:drafter,
        :important_flag,:category,:do_staff,:check_staff)
    end
end
