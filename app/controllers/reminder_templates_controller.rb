class ReminderTemplatesController < AdminController
  before_action :set_reminder_template, only: %i[ show edit update destroy ]

  def hand_reflect
    date = Date.today
    new_reminders = []
    reminder_template = ReminderTemplate.find(params[:reminder_template_id])
    reminder_template.stores.each do |store|
      reminder = Reminder.new(store_id:store.id,reminder_template_id:reminder_template.id,action_date:date,drafter:reminder_template.drafter,
        action_time:reminder_template.action_time,content:reminder_template.content,memo:reminder_template.memo,status:0)
      new_reminders << reminder
    end
    Reminder.import new_reminders
    redirect_to reminder_templates_path
  end
  def clean
    @reminder_templates = ReminderTemplate.where(category:1).order(:action_time)
    @reminder_templates = @reminder_templates.joins(:reminder_template_stores).where(:reminder_template_stores => {store_id:params[:store_id]}) if params[:store_id].present?
    @reminder_templates = @reminder_templates.where(repeat_type:params[:repeat_type]) if params[:repeat_type].present?
  end
  def index
    if params[:category] == 'clean'
      category = 1
    else
      category = 0
    end
    @reminder_templates = ReminderTemplate.where(category:category).order(:action_time)
    @reminder_templates = @reminder_templates.joins(:reminder_template_stores).where(:reminder_template_stores => {store_id:params[:store_id]}) if params[:store_id].present?
    @reminder_templates = @reminder_templates.where(repeat_type:params[:repeat_type]) if params[:repeat_type].present?
  end

  def show
  end

  def new
    if params[:category]
      category = params[:category]
    else
      category = 0
    end
    @reminder_template = ReminderTemplate.new(category:category)
    @stores = Store.where(group_id:current_user.group_id).where.not(id:39)
    new_store_ids = @stores.ids
    @stores_hash = {}
    @stores.each do |store|
      @stores_hash[store.id]=store.name
      @reminder_template.reminder_template_stores.build(store_id:store.id)
    end
  end

  def edit
    @category = @reminder_template.category
    store_ids = @reminder_template.reminder_template_stores.pluck(:store_id)
    @stores = Store.where(group_id:current_user.group_id).where.not(id:39)
    all_store_ids = @stores.ids
    new_store_ids = all_store_ids - store_ids
    @stores_hash = {}
    Store.all.each do |store|
      @stores_hash[store.id]=store.name
    end

    new_store_ids.each do |store_id|
      @reminder_template.reminder_template_stores.build(store_id:store_id)
    end
  end

  def create
    @reminder_template = ReminderTemplate.new(reminder_template_params)
    respond_to do |format|
      if @reminder_template.save
        format.html { redirect_to reminder_templates_path, notice: "Reminder Template was successfully created." }
        format.json { render :show, status: :created, location: @reminder_template }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @reminder_template.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @reminder_template.update(reminder_template_params)
        format.html { redirect_to reminder_templates_path, notice: "Reminder Template was successfully updated." }
        format.json { render :show, status: :ok, location: @reminder_template }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @reminder_template.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @reminder_template.destroy
    respond_to do |format|
      format.html { redirect_to reminder_templates_url, notice: "Reminder Template was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_reminder_template
      @reminder_template = ReminderTemplate.find(params[:id])
    end

    def reminder_template_params
      params.require(:reminder_template).permit(:repeat_type,:action_time,:content,:memo,:status,:drafter,:category,
      reminder_template_stores_attributes: [:id, :store_id,:reminder_template_id,:_destroy])
    end
end
