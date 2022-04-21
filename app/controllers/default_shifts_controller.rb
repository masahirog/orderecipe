class DefaultShiftsController < ApplicationController
  before_action :set_default_shift, only: %i[ show edit update destroy ]
  def create_frame
    @wdays = [[1,'月'],[2,'火'],[3,'水'],[4,'木'],[5,'金'],[6,'土'],[0,'日']]
    group = Group.find(params[:group_id])
    store_ids = group.stores.ids
    staff_ids = Staff.where(status:0,store_id:store_ids).ids
    default_staff_ids = DefaultShift.all.map{|ds|ds.staff_id}.uniq
    new_staff_ids = staff_ids - default_staff_ids
    new_arr = []
    new_staff_ids.each do |staff_id|
      @wdays.each do |wday|
        new_arr << DefaultShift.new(staff_id:staff_id,weekday:wday[0])
      end
    end
    DefaultShift.import new_arr
    redirect_to default_shifts_path(group_id:params[:group_id]),notice:"デフォルトシフト枠を作成しました。"
  end
  def index
    @group = Group.find(params[:group_id])
    store_ids = @group.stores.ids
    @stores = Store.where(id:store_ids)
    @fix_shift_patterns = FixShiftPattern.where(group_id:@group.id)
    @staffs = Staff.where(status:0,store_id:store_ids)
    @wdays = [[1,'月'],[2,'火'],[3,'水'],[4,'木'],[5,'金'],[6,'土'],[0,'日']]
    default_shifts = DefaultShift.where(staff_id:@staffs.ids)
    @default_shifts = default_shifts.map{|default_shift|[[default_shift.staff_id,default_shift.weekday],default_shift]}.to_h
    @rowspan = @group.shift_frames.count
    @shift_frames = @group.shift_frames
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
      params.require(:default_shift).permit(:weekday,:staff_id,:fix_shift_pattern_id,:memo,:store_id)
    end
end
