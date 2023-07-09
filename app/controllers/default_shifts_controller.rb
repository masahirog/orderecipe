class DefaultShiftsController < ApplicationController
  before_action :set_default_shift, only: %i[ show edit update destroy ]
  def create_frame
    @wdays = [[1,'月'],[2,'火'],[3,'水'],[4,'木'],[5,'金'],[6,'土'],[0,'日']]

    @group = Group.find(params[:group_id])
    if params[:store_type].present?
      @store_type = params[:store_type]
      @stores = @group.stores.where(store_type:@store_type)
    else
      @store_type = nil
      @stores = @group.stores
    end
    if params[:stores]
      @checked_stores = Store.where(id:params['stores'].keys)
    else
      @checked_stores = @stores
      params[:stores] = {}
      @stores.each do |store|
        params[:stores][store.id.to_s] = true
      end
    end
    staff_ids = @checked_stores.map{|store|store.staffs.ids}.flatten.uniq
    default_staff_ids = DefaultShift.all.map{|ds|ds.staff_id}.uniq
    new_staff_ids = staff_ids - default_staff_ids
    new_arr = []
    new_staff_ids.each do |staff_id|
      @wdays.each do |wday|
        new_arr << DefaultShift.new(staff_id:staff_id,weekday:wday[0])
      end
    end
    DefaultShift.import new_arr
    redirect_to default_shifts_path(group_id:params[:group_id],store_type:@store_type),success:"デフォルトシフト枠を作成しました。"
  end

  def index
    @times_arr = ["5:00","5:15","5:30","5:45","6:00","6:15","6:30","6:45","7:00","7:15","7:30","7:45","8:00","8:15","8:30","8:45","9:00",
      "9:15","9:30","9:45","10:00","10:15","10:30","10:45","11:00","11:15","11:30","11:45","12:00","12:15","12:30","12:45","13:00","13:15",
      "13:30","13:45","14:00","14:15","14:30","14:45","15:00","15:15","15:30","15:45","16:00","16:15","16:30","16:45","17:00","17:15","17:30",
      "17:45","18:00","18:15","18:30","18:45","19:00","19:15","19:30","19:45","20:00","20:15","20:30","20:45","21:00","21:15","21:30","21:45",
      "22:00","22:15","22:30"]

    @group = Group.find(params[:group_id])
    if params[:store_type].present?
      @store_type = params[:store_type]
      @stores = @group.stores.includes(:fix_shift_pattern_stores,store_shift_frames:[:shift_frame]).where(store_type:@store_type)
    else
      @store_type = nil
      @stores = @group.stores.includes(:fix_shift_pattern_stores,store_shift_frames:[:shift_frame])
    end
    if params[:stores]
      @checked_stores = Store.where(id:params['stores'].keys)
    else
      @checked_stores = @stores
      params[:stores] = {}
      @stores.each do |store|
        params[:stores][store.id.to_s] = true
      end
    end
    @fix_shift_patterns = FixShiftPattern.where(group_id:@group.id)
    staff_ids = @checked_stores.map{|store|store.staffs.ids}.flatten.uniq
    @staffs = Staff.where(status:0,id:staff_ids).order(row:'asc')
    @wdays = [[1,'月'],[2,'火'],[3,'水'],[4,'木'],[5,'金'],[6,'土'],[0,'日']]
    default_shifts = DefaultShift.where(staff_id:@staffs.ids)
    @default_shifts = default_shifts.map{|default_shift|[[default_shift.staff_id,default_shift.weekday],default_shift]}.to_h
    # @shift_frames = @group.shift_frames


    @staff_syukkin_count = default_shifts.joins(:fix_shift_pattern).where.not(:fix_shift_patterns=>{working_hour:0}).where.not(fix_shift_pattern_id: nil).group(:staff_id).count
    @date_store_working_count = default_shifts.joins(:fix_shift_pattern).where.not(:fix_shift_patterns=>{working_hour:0}).where.not(fix_shift_pattern_id: nil).group(:weekday,:store_id).count
    @staff_working_hour = default_shifts.joins(:fix_shift_pattern).where.not(:fix_shift_patterns=>{working_hour:0}).where.not(fix_shift_pattern_id: nil).group(:staff_id).sum("fix_shift_patterns.working_hour")
    @date_store_working_hour = default_shifts.joins(:fix_shift_pattern).where.not(:fix_shift_patterns=>{working_hour:0}).where.not(fix_shift_pattern_id: nil).group(:weekday,:store_id).sum("fix_shift_patterns.working_hour")


    @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    default_shifts.each do |default_shift|
      if default_shift.fix_shift_pattern_id.present?
        weekday = default_shift.weekday
        store_id = default_shift.store_id
        working_hour = default_shift.fix_shift_pattern.working_hour
        default_shift.fix_shift_pattern.shift_frames.each do |sf|
          if @hash[store_id][weekday][sf.id].present?
            @hash[store_id][weekday][sf.id]['working_number'] += 1
            @hash[store_id][weekday][sf.id]['working_hour'] += working_hour
          else
            @hash[store_id][weekday][sf.id]['working_number'] = 1
            @hash[store_id][weekday][sf.id]['working_hour'] = working_hour
          end
        end
      end
    end
  end

  def show
  end

  def new
    @default_shift = DefaultShift.new
  end

  def edit
  end

  def create
    @default_shift = DefaultShift.new(default_shift_params)

    respond_to do |format|
      if @default_shift.save
        format.html { redirect_to @default_shift, notice: "Default shift was successfully created." }
        format.json { render :show, status: :created, location: @default_shift }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @default_shift.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @default_shift.fix_shift_pattern_id_was.present?
      before_fix_shift_pattern_id = @default_shift.fix_shift_pattern_id_was
      @before_fix_shift_pattern = FixShiftPattern.find(before_fix_shift_pattern_id)
      @before_shift_frames = @before_fix_shift_pattern.shift_frames
    end
    if @default_shift.store_id_was.present?
      @before_store_id = @default_shift.store_id_was
      @before_store = Store.find(@before_store_id)
    end
    if @default_shift.store_id_was == params[:default_shift][:store_id].to_i
    else
      @store_change_flag = true
      params[:default_shift][:fix_shift_pattern_id]=""
    end
    if params[:default_shift][:store_id].present?
      store = Store.find(params[:default_shift][:store_id])
      @fix_shift_patterns = store.fix_shift_patterns
    else
      @fix_shift_patterns = []
    end

    respond_to do |format|
      if @default_shift.update(default_shift_params)
        if @default_shift.store_id.present?
          @store = @default_shift.store
        end
        if @default_shift.fix_shift_pattern.present?
          @default_shift_frames = @default_shift.fix_shift_pattern.shift_frames
        end
        format.html { redirect_to @default_shift, notice: "Shift was successfully updated." }
        format.js
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def destroy
    @default_shift.destroy
    respond_to do |format|
      format.html { redirect_to default_shifts_url, notice: "Default shift was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_default_shift
      @default_shift = DefaultShift.find(params[:id])
    end

    def default_shift_params
      params.require(:default_shift).permit(:weekday,:staff_id,:fix_shift_pattern_id,:memo,:store_id,:start_time,:end_time)
    end
end
