class WorkingHoursController < AdminController
  before_action :set_working_hour, only: %i[ show edit update destroy ]

  def position_daily
    date = "#{params[:month]}-01".to_date
    @month = "#{date.year}-#{sprintf("%02d",date.month)}"
    if params[:to].present?
      @to = Date.parse(params[:to])
    else
      @to = @today
    end
    if params[:from].present?
      @from = Date.parse(params[:from])
    else
      @from = @to - 30
    end
    @dates = (@from..@to).to_a
    @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    WorkingHour.includes(working_hour_work_types:[:work_type]).where(date:@dates,store_id:39).order(:date).each do |working_hour|
      working_hour.working_hour_work_types.each do |whwt|
        if @hash[working_hour.date][whwt.work_type.category_before_type_cast].present?
          @hash[working_hour.date][whwt.work_type.category_before_type_cast] += whwt.worktime
        else
          @hash[working_hour.date][whwt.work_type.category_before_type_cast] = whwt.worktime
        end
      end
    end
  end

  def monthly
    if params[:year].present?
      @year = params[:year]
      @date = Date.new(@year,1,1)
    else
      @date = @today
      @year = "#{@date.year}"
    end
    @years = (2024..2030).to_a
    @months = (1..12).to_a
    @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @months.each do |month|
      from = Date.new(@year.to_i,month,1)
      to = from.end_of_month
      working_hours = WorkingHour.where(date:from..to)
      @hash[month] = WorkingHourWorkType.joins(:work_type).where(working_hour_id:working_hours.ids).group("work_types.category").sum(:worktime)
      @hash[month][:count] = working_hours.map{|wh|wh.date}.uniq.length
    end
    @categories = WorkType.categories
  end

  def detail
    if params[:date].present?
      @date = Date.parse(params[:date])
    else
      @date = Date.today
    end
    gon.date = @date
    @working_hour_work_type = WorkingHourWorkType.new()
    gon.working_hours = []
    gon.events = []
    hash = {}
    @working_hours = WorkingHour.includes(:staff).where(date:@date,store_id:39)
    @working_hours.each do |wh|
      gon.working_hours << { id: wh.id, title: wh.staff.short_name}
    end
    @work_types = WorkType.order(:row_order)
    @work_type_categories = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    WorkingHourWorkType.includes(:work_type).where("start >= ? AND start < ?", @date, @date + 1).each_with_index do |whwt,i|
      hash[whwt.js_event_id] = whwt
      if @work_type_categories[whwt.work_type.category_before_type_cast].present?
        @work_type_categories[whwt.work_type.category_before_type_cast] += whwt.worktime
      else
        @work_type_categories[whwt.work_type.category_before_type_cast] = whwt.worktime
      end
      gon.events << {
        id: whwt.js_event_id,
        resourceIds: [whwt.working_hour_id],
        start: whwt.start,
        end: whwt.end,
        title: "#{whwt.work_type.name}\n#{whwt.memo}",
        startEditable: false,
        durationEditable: false,
        backgroundColor: "#{whwt.work_type.bg_color_code}",
        editable: true,
      }
    end
    gon.work_type_hash = hash
    @shift_hash = {count:0,time:0}
    Shift.includes(:fix_shift_pattern).where(date:@date,store_id:39).each do |shift|
      @shift_hash[shift.staff_id] = shift
      if shift.fix_shift_pattern_id.present? && shift.fix_shift_pattern.working_hour > 0
        @shift_hash[:count] += 1
        @shift_hash[:time] += shift.fix_shift_pattern.working_hour
      end
    end
    @working_hour_whwt_hash = WorkingHourWorkType.where("start >= ? AND start < ?", @date, @date + 1).group(:working_hour_id).sum(:worktime)
  end
  def daily
    date = "#{params[:month]}-01".to_date
    @month = "#{date.year}-#{sprintf("%02d",date.month)}"
    @shift_dates =(date.beginning_of_month..date.end_of_month).to_a
    @working_dates = (date..@today-1).to_a
    kijun = {"28" => 160,"29" => 165.7,"30" => 171.4,"31" => 177.1}
    @max_woriking_time = kijun[@shift_dates.length.to_s] + 20
    if @today.day == 1
      @progress_rate = @shift_dates.length.to_f
    else
      @progress_rate = (@shift_dates.length.to_f / (@today.day - 1)).round(1)
    end

    @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @shift_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @hash[:total_time][:all] = 0
    @hash[:total_time][:employee] = 0
    @hash[:total_time][:part_time] = 0
    WorkingHour.includes(:staff).where(date:@working_dates,store_id:39).each do |working_hour|
      @hash[:total_time][:all] += working_hour.working_time
      @hash[:total_time][:employee] += working_hour.working_time if working_hour.staff.employment_status == "employee"
      @hash[:total_time][:part_time] += working_hour.working_time if working_hour.staff.employment_status == "part_time"
      if @hash[:daily][working_hour.date].present?
        @hash[:daily][working_hour.date][:total_time] += working_hour.working_time
        @hash[:daily][working_hour.date][working_hour.staff_id][:working_time] = working_hour.working_time if working_hour.working_time > 0
        if @hash[:daily][working_hour.date][working_hour.staff.employment_status].present?
          @hash[:daily][working_hour.date][working_hour.staff.employment_status][:total_time] += working_hour.working_time
        else
          @hash[:daily][working_hour.date][working_hour.staff.employment_status][:total_time] = working_hour.working_time
        end
      else
        @hash[:daily][working_hour.date][:total_time] = working_hour.working_time
        @hash[:daily][working_hour.date][working_hour.staff_id][:working_time] = working_hour.working_time if working_hour.working_time > 0
        if @hash[:daily][working_hour.date][working_hour.staff.employment_status].present?
          @hash[:daily][working_hour.date][working_hour.staff.employment_status][:total_time] += working_hour.working_time
        else
          @hash[:daily][working_hour.date][working_hour.staff.employment_status][:total_time] = working_hour.working_time
        end
      end
      if @hash[:staff][working_hour.staff_id].present?
        @hash[:staff][working_hour.staff_id][:working_time] += working_hour.working_time
        @hash[:staff][working_hour.staff_id][:working_count] += 1 if working_hour.working_time > 0
      else
        @hash[:staff][working_hour.staff_id][:working_time] = working_hour.working_time
        if working_hour.working_time > 0
          @hash[:staff][working_hour.staff_id][:working_count] = 1
        else
          @hash[:staff][working_hour.staff_id][:working_count] = 0
        end

      end
    end

    @shift_hash[:total_time][:all] = 0
    @shift_hash[:total_time][:employee] = 0
    @shift_hash[:total_time][:part_time] = 0
    Shift.includes(:fix_shift_pattern,:staff).where(date:@shift_dates,store_id:39).where.not(fix_shift_pattern_id:nil).each do |shift|
      @shift_hash[:total_time][:all] += shift.fix_shift_pattern.working_hour
      @shift_hash[:total_time][:employee] += shift.fix_shift_pattern.working_hour if shift.staff.employment_status == "employee"
      @shift_hash[:total_time][:part_time] += shift.fix_shift_pattern.working_hour if shift.staff.employment_status == "part_time"
      if @shift_hash[:daily][shift.date].present?
        @shift_hash[:staff][shift.staff_id][:daily][shift.date][:working_time] = shift.fix_shift_pattern.working_hour if shift.fix_shift_pattern.working_hour > 0
        @shift_hash[:daily][shift.date][:total_time] += shift.fix_shift_pattern.working_hour
        if @shift_hash[:daily][shift.date][shift.staff.employment_status].present?
          @shift_hash[:daily][shift.date][shift.staff.employment_status][:total_time] += shift.fix_shift_pattern.working_hour
        else
          @shift_hash[:daily][shift.date][shift.staff.employment_status][:total_time] = shift.fix_shift_pattern.working_hour
        end
      else
        @shift_hash[:staff][shift.staff_id][:daily][shift.date][:working_time] = shift.fix_shift_pattern.working_hour if shift.fix_shift_pattern.working_hour > 0
        if @shift_hash[:daily][shift.date][shift.staff.employment_status].present?
          @shift_hash[:daily][shift.date][shift.staff.employment_status][:total_time] += shift.fix_shift_pattern.working_hour
        else
          @shift_hash[:daily][shift.date][shift.staff.employment_status][:total_time] = shift.fix_shift_pattern.working_hour
        end
        @shift_hash[:daily][shift.date][:total_time] = shift.fix_shift_pattern.working_hour
      end


      if @shift_hash[:staff][shift.staff.employment_status][shift.staff_id].present?
        @shift_hash[:staff][shift.staff.employment_status][shift.staff_id][:total_time] += shift.fix_shift_pattern.working_hour
      else
        @shift_hash[:staff][shift.staff.employment_status][shift.staff_id][:staff] = shift.staff
        @shift_hash[:staff][shift.staff.employment_status][shift.staff_id][:total_time] = shift.fix_shift_pattern.working_hour
      end      
    end
  end


  def create_work_times
    new_arr = []
    whwt_arr = []
    @date = Date.parse(params[:date])
    working_hour_hash = WorkingHour.where(date:params[:date]).map{|wh|[[wh.date,wh.staff_id],wh]}.to_h
    staff_ids = StaffStore.where(store_id:39).map{|ss|ss.staff_id}.uniq
    Staff.where(id:staff_ids,status:0).each do |staff|
      if working_hour_hash[[@date,staff.id]].present?
      else
        new_working_hour = WorkingHour.new(date:@date,staff_id:staff.id,store_id:39,working_time:0)
        new_arr << new_working_hour
      end
    end
    WorkingHour.import new_arr
    @working_hours = WorkingHour.where(date:@date,store_id:39)
    redirect_to detail_working_hours_path(date:@date),info:"枠を作成しました。"
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
        format.js
      else
        format.html { render :new, status: :unprocessable_entity }
        format.js
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
      params.require(:working_hour).permit(:id,:store_id,:staff_id,:date,:working_time)
    end
end

