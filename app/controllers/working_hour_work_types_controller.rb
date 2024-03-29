class WorkingHourWorkTypesController < ApplicationController
  before_action :set_working_hour_work_type, only: %i[ show edit ]
  before_action :set_event_id_working_hour_work_type, only: %i[ update ]
  protect_from_forgery :except => [:destroy]

  def time_change
    @working_hour_work_type = WorkingHourWorkType.find_by(js_event_id:params[:event][:id])
    working_hour_id = params[:event][:resourceIds].join
    working_hour = WorkingHour.find(working_hour_id)
    start_time = DateTime.parse(params[:event][:start])
    end_time = DateTime.parse(params[:event][:end])
    work_type = @working_hour_work_type.work_type
    if work_type.rest_flag == true
      work_time_minute = 0
    else
      work_time_minute = (end_time.to_time - start_time.to_time)/60
    end
    work_time_hour = (work_time_minute/60).round(1)
    @working_hour_work_type.update(start:start_time,end:end_time,working_hour_id:working_hour_id,worktime:work_time_minute)
    worktime = (working_hour.working_hour_work_types.sum(:worktime)/60).round(1)
    working_hour.update(working_time:worktime)
    respond_to do |format|
      format.json { render json: { working_hour_id:working_hour_id,worktime:worktime } }
    end
  end

  def working_hour_change
    @working_hour_work_type = WorkingHourWorkType.find_by(js_event_id:params[:event][:id])
    working_hour_id_was = @working_hour_work_type.working_hour_id_was
    working_hour_was = WorkingHour.find(working_hour_id_was)
    working_hour_id = params[:event][:resourceIds].join
    working_hour = WorkingHour.find(working_hour_id)
    start_time = DateTime.parse(params[:event][:start])
    end_time = DateTime.parse(params[:event][:end])

    work_type = @working_hour_work_type.work_type
    if work_type.rest_flag == true
      work_time_minute = 0
    else
      work_time_minute = (end_time.to_time - start_time.to_time)/60
    end
    work_time_hour = (work_time_minute/60).round(1)
    @working_hour_work_type.update(start:start_time,end:end_time,working_hour_id:working_hour_id,worktime:work_time_minute)
    working_hour_id_worktime = (working_hour.working_hour_work_types.sum(:worktime)/60).round(1)
    working_hour.update(working_time:working_hour_id_worktime)
    working_hour_id_was_worktime = 0
    working_hour_id_was_worktime = (working_hour_was.working_hour_work_types.sum(:worktime)/60).round(1)
    working_hour_was.update(working_time:working_hour_id_was_worktime)

    respond_to do |format|
      format.json { render json: { working_hour_id:working_hour_id,working_hour_id_worktime:working_hour_id_worktime,
        working_hour_id_was:working_hour_id_was,working_hour_id_was_worktime:working_hour_id_was_worktime } }
    end
  end


  def index
    @working_hour_work_types = WorkingHourWorkType.all
  end

  def show
  end

  def new
    @working_hour_work_type = WorkingHourWorkType.new
  end

  def edit
  end

  def create
    working_hour_id = params[:working_hour_work_type][:working_hour_id]
    @working_hour = WorkingHour.find(working_hour_id)
    date = @working_hour.date
    @working_hour_work_type = WorkingHourWorkType.new(working_hour_work_type_params)
    @working_hour_work_type.start = DateTime.parse("#{date} #{params[:working_hour_work_type][:start]} JST +09:00")
    @working_hour_work_type.end = DateTime.parse("#{date} #{params[:working_hour_work_type][:end]} JST +09:00")
    work_type = @working_hour_work_type.work_type
    if work_type.rest_flag == true
      work_time_minute = 0
      work_time_hour = 0
    else
      work_time_minute = (@working_hour_work_type.end - @working_hour_work_type.start)/60
      work_time_hour = (work_time_minute/60).round(1)
    end
    @working_hour_work_type.worktime = work_time_minute
    work_time_hour = (@working_hour.working_time + work_time_hour).round(1)
    @working_hour.update(working_time:work_time_hour)
    respond_to do |format|
      if @working_hour_work_type.save
        format.html { redirect_to working_hour_work_type_url(@working_hour_work_type), notice: "Working hour work type was successfully created." }
        format.js
      else
        format.html { render :new, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def update
    @working_hour = @working_hour_work_type.working_hour
    replace_working_hour_work_type_params = working_hour_work_type_params
    workstart = DateTime.parse("#{@working_hour.date} #{params[:working_hour_work_type][:start]} JST +09:00")
    replace_working_hour_work_type_params[:start] = workstart
    workend = DateTime.parse("#{@working_hour.date} #{params[:working_hour_work_type][:end]} JST +09:00")
    replace_working_hour_work_type_params[:end] = workend
    work_type = WorkType.find_by(id:params[:working_hour_work_type][:work_type_id])
    if work_type.rest_flag == true
      work_time_minute = 0
    else
      work_time_minute = (workend.to_time - workstart.to_time)/60
    end
    replace_working_hour_work_type_params[:worktime] = work_time_minute

    respond_to do |format|
      if @working_hour_work_type.update(replace_working_hour_work_type_params)
        working_hour_id_worktime = (@working_hour.working_hour_work_types.sum(:worktime)/60).round(1)
        @working_hour.update(working_time:working_hour_id_worktime)
        format.html { redirect_to working_hour_work_type_url(@working_hour_work_type), notice: "Working hour work type was successfully updated." }
        format.js
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def destroy
    @working_hour_work_type = WorkingHourWorkType.find_by(js_event_id:params[:id])
    working_hour_id = @working_hour_work_type.working_hour_id
    working_hour = WorkingHour.find(working_hour_id)
    @working_hour_work_type.destroy
    worktime = (working_hour.working_hour_work_types.sum(:worktime)/60).round(1)
    respond_to do |format|
      format.json { render json: { working_hour_id:working_hour_id,worktime:worktime } }
    end
  end

  private
    def set_working_hour_work_type
      @working_hour_work_type = WorkingHourWorkType.find(params[:id])
    end
    def set_event_id_working_hour_work_type
      @working_hour_work_type = WorkingHourWorkType.find_by(js_event_id:params[:working_hour_work_type][:js_event_id])
    end
    def working_hour_work_type_params
      params.require(:working_hour_work_type).permit(:id,:working_hour_id,:work_type_id,:start,:end,:worktime,:memo,:js_event_id)
    end
end
