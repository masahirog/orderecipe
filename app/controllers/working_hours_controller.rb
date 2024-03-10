class WorkingHoursController < AdminController
  before_action :set_working_hour, only: %i[ show edit update destroy ]
  def monthly
    date = "#{params[:month]}-01".to_date
    dates =(date.beginning_of_month..date.end_of_month).to_a
    @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @shift_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @hash[:total_time] = 0
    WorkingHour.includes(:staff).where(date:dates,store_id:39).each do |working_hour|
      @hash[:total_time] += working_hour.working_time
      if @hash[:daily][working_hour.date].present?
        @hash[:daily][working_hour.date][:total_time] += working_hour.working_time
      else
        @hash[:daily][working_hour.date][:total_time] = working_hour.working_time
      end
      if @hash[:staff][working_hour.staff_id].present?
        @hash[:staff][working_hour.staff_id][:total_time] += working_hour.working_time
      else
        @hash[:staff][working_hour.staff_id][:staff] = working_hour.staff
        @hash[:staff][working_hour.staff_id][:total_time] = working_hour.working_time
      end
    end
    @shift_hash[:total_time] = 0
    Shift.where(date:dates,store_id:39).each do |shift|
      @shift_hash[:total_time] += shift.fix_shift_pattern.working_hour
      if @shift_hash[:daily][shift.date].present?
        @shift_hash[:daily][shift.date][:total_time] += shift.fix_shift_pattern.working_hour
      else
        @shift_hash[:daily][shift.date][:total_time] = shift.fix_shift_pattern.working_hour
      end
      if @shift_hash[:staff][shift.staff_id].present?
        @shift_hash[:staff][shift.staff_id][:total_time] += shift.fix_shift_pattern.working_hour
      else
        @shift_hash[:staff][shift.staff_id][:staff] = shift.staff
        @shift_hash[:staff][shift.staff_id][:total_time] = shift.fix_shift_pattern.working_hour
      end      
    end
  end

  def staff_input
    if params[:date]
      @date = Date.parse(params[:date])
    else
      @date = Date.today
    end
    @month = "#{@date.year}-#{sprintf("%02d",@date.month)}"
    @working_hours = WorkingHour.includes(:staff).where(date:@date)
    @shift_hash = {count:0,time:0}
    Shift.includes(:fix_shift_pattern).where(date:@date,store_id:39).each do |shift|
      @shift_hash[[shift.staff_id,shift.date]] = shift
      if shift.fix_shift_pattern_id.present? && shift.fix_shift_pattern.working_hour > 0
        @shift_hash[:count] += 1
        @shift_hash[:time] += shift.fix_shift_pattern.working_hour
      end
    end
    @times = []
    15.times do |hour|
      [["00",0.0],["15",0.25],["30",0.5],["45",0.75]].each do |min|
        @times  << ["#{hour}:#{min[0]}",(hour + min[1])]
      end
    end
  end
  def create_work_times
    new_arr = []
    @date = Date.parse(params[:date])
    working_hour_hash = WorkingHour.where(date:params[:date]).map{|wh|[[wh.date,wh.staff_id],wh]}.to_h
    staff_ids = StaffStore.where(store_id:39).map{|ss|ss.staff_id}.uniq
    Staff.where(id:staff_ids,status:0).each do |staff|
      if working_hour_hash[[@date,staff.id]].present?
      else
        new_arr << WorkingHour.new(date:@date,staff_id:staff.id,store_id:39,working_time:0)
      end
    end
    WorkingHour.import new_arr
    redirect_to staff_input_working_hours_path(date:@date)
  end

  def upload_data
    group_id = params[:group_id]
    WorkingHour.upload_data(params[:file],group_id)
    redirect_to working_hours_path(group_id:group_id), :notice => "ジョブカンデータをアップロードしました。"
  end

  def index
    today = Date.today
    @group = current_user.group
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
    if params[:working_hour][:end_time].present? && params[:working_hour][:start_time].present?
      restraint_time = ((params[:working_hour][:end_time].to_time - params[:working_hour][:start_time].to_time)/3600).round(1)
    else
      restraint_time = 0
    end
    working_time = restraint_time - (params[:working_hour][:break_minutes].to_f/60).round(1)
    respond_to do |format|
      if @working_hour.update(working_hour_params.merge(working_time: working_time))
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
      params.require(:working_hour).permit(:id,:store_id,:staff_id,:date,:start_time,:end_time,:working_time,:break_minutes)
    end
end

