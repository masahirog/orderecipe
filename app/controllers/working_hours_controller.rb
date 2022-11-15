class WorkingHoursController < ApplicationController
  before_action :set_working_hour, only: %i[ show edit update destroy ]
  def staff_input
    @group = Group.find(params[:group_id])
    @times = []
    15.times do |hour|
      [["00",0.0],["15",0.25],["30",0.5],["45",0.75]].each do |min|
        @times  << ["#{hour}:#{min[0]}",(hour + min[1])]
      end
    end
    today = Date.today
    @staffs = WorkingHour.where(group_id:19).pluck(:name).uniq
    if params[:date]
      @date = Date.parse(params[:date])
    else
      @date = today
    end
    @working_hours = WorkingHour.where(date:@date).where(group_id:19)
    if @working_hours.present?
    else
    end
  end
  def create_work_times
    new_arr = []
    @date = Date.parse(params[:date])
    working_hour_hash = WorkingHour.where(date:params[:date]).map{|wh|[[wh.date,wh.staff_id],wh]}.to_h
    Staff.joins(:store).where(:stores => {group_id:19}).where(status:0).each do |staff|
      if working_hour_hash[[@date,staff.id]].present?
      else
        new_arr << WorkingHour.new(date:@date,group_id:19,staff_id:staff.id,name:staff.name,jobcan_staff_code:staff.jobcan_staff_code,store_id:39)
      end
    end
    WorkingHour.import new_arr
    redirect_to staff_input_working_hours_path(date:@date)
  end

  def upload_jobcan_data
    group_id = params[:group_id]
    WorkingHour.upload_data(params[:file],group_id)
    redirect_to working_hours_path(group_id:group_id), :notice => "ジョブカンデータをアップロードしました。"
  end

  def index
    today = Date.today
    @group = Group.find(params[:group_id])
    @staffs = WorkingHour.where(group_id:@group.id).pluck(:name).uniq
    if params[:from]
      @from = params[:from]
    else
      @from = today
    end
    if params[:to]
      @to = params[:to]
    else
      @to = today
    end
    @working_hours = WorkingHour.where(date:@from..@to).where(group_id:@group.id)
    @working_hours = @working_hours.where(name:params[:name]) if params[:name].present?
    @working_hours = @working_hours.page(params[:page]).per(50)
  end

  def show
  end

  def new
    @working_hour = WorkingHour.new
  end

  def edit
  end

  def create
    @working_hour = WorkingHour.new(working_hour_params)

    respond_to do |format|
      if @working_hour.save
        format.html { redirect_to working_hour_url(@working_hour), notice: "Working hour was successfully created." }
        format.json { render :show, status: :created, location: @working_hour }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @working_hour.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @position = params["working_hour"]["position"]
    respond_to do |format|
      if @working_hour.update(working_hour_params)
        format.html
        format.js
      else
        format.html
        format.js
      end
    end
  end

  def destroy
    @working_hour.destroy
    respond_to do |format|
      format.html { redirect_to working_hours_url, notice: "Working hour was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_working_hour
      @working_hour = WorkingHour.find(params[:id])
    end

    def working_hour_params
      params.require(:working_hour).permit(:id,:date,:name,:working_time,:jobcan_staff_code,:store_id,:group_id,:position,
      :kari_working_time,:chori_of_working_time,:kiridashi_of_working_time,:moritsuke_of_working_time,:sekisai_of_working_time,:sonota_of_working_time,:tare_of_working_time)

    end
end
