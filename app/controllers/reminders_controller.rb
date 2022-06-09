class RemindersController < ApplicationController
  before_action :set_reminder, only: %i[ show edit update destroy ]
  def store
    if params[:date]
      @date = Date.parse(params[:date])
    else
      @date = Date.today
      params[:date]=@date
    end
    @store = Store.find(params[:store_id])
    @reminders = @store.reminders.where(action_date:@date).order(:action_time)
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
        Reminder.chatwork_notice(@reminder,params['stores']) if params['chatwork_notice'].present?
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
      params.require(:reminder).permit(:store_id,:reminder_template_id,:action_date,:action_time,:content,:memo,:status,:status_change_datetime,:drafter,:important_flag)
    end
end
