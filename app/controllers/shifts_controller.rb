class ShiftsController < ApplicationController
  before_action :set_shift, only: %i[ show edit update destroy ]
  def store
    if params[:date]
      @date = Date.parse(params[:date])
    else
      @date = Date.today
    end
    first_day = @date.beginning_of_month
    last_day = first_day.end_of_month
    @one_month = [*first_day..last_day]
    @shifts = Shift.includes([:staff,:fix_shift_pattern]).where(date:@one_month).where.not(fix_shift_pattern_id:nil)
    @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @shifts.each do |shift|
      if @hash[shift.store_id][shift.date].present?
        if shift.fix_shift_pattern.section == 'lunch'
          @hash[shift.store_id][shift.date]['lunch'] << shift.staff.name
        elsif shift.fix_shift_pattern.section == 'dinner'
          @hash[shift.store_id][shift.date]['dinner'] << shift.staff.name
        elsif shift.fix_shift_pattern.section == 'all_day'
          @hash[shift.store_id][shift.date]['lunch'] << shift.staff.name
          @hash[shift.store_id][shift.date]['dinner'] << shift.staff.name
        end
      else
        if shift.fix_shift_pattern.section == 'lunch'
          @hash[shift.store_id][shift.date]['lunch'] = [shift.staff.name]
          @hash[shift.store_id][shift.date]['dinner'] = []
        elsif shift.fix_shift_pattern.section == 'dinner'
          @hash[shift.store_id][shift.date]['lunch'] = []
          @hash[shift.store_id][shift.date]['dinner'] = [shift.staff.name]
        elsif shift.fix_shift_pattern.section == 'all_day'
          @hash[shift.store_id][shift.date]['lunch'] = [shift.staff.name]
          @hash[shift.store_id][shift.date]['dinner'] = [shift.staff.name]
        end
      end
    end
    @stores = Store.where.not(id:39)
  end
  def once_update
    date = params["date"]
    shinsei_shift_hash = params["shifts"]
    shift_ids = shinsei_shift_hash.keys
    shifts = Shift.where(id:shift_ids)
    update_shifts = []
    shifts.each do |shift|
      shinsei_shift = shinsei_shift_hash[shift.id.to_s]
      shift.shift_pattern_id = shinsei_shift['shift_pattern_id']
      shift.memo = shinsei_shift['memo']
      update_shifts << shift
    end
    updated_shifts = Shift.import update_shifts, on_duplicate_key_update:[:memo,:shift_pattern_id]
    redirect_to check_shifts_path(date:date),:notice => "シフトを申請しました。"
  end
  def staff_edit
    staff_id = params[:staff_id]
    @staff = Staff.find(staff_id)
    date = params[:date]
    if staff_id.present? && date.present?
      @date = Date.parse(params[:date])
      first_day = @date.beginning_of_month
      last_day = first_day.end_of_month
      @one_month = [*first_day..last_day]
      @shifts = Shift.where(staff_id:staff_id,date:@one_month)
      @shift_patterns = ShiftPattern.all.order(pattern_name:'DESC')
      if @shifts.present?
      else
        redirect_to check_shifts_path, :alert => 'シフトの申請枠が無いため、社員に連絡をしてください。'
      end
    else
      redirect_to check_shifts_path, :alert => '頂いた情報では、シフトの申請は出来ません。'
    end
  end

  def check
    params[:group_id] = '9'
    if params[:date]
      @date = Date.parse(params[:date])
    else
      @date = Date.today
    end
    @year_months = [["#{@date.year}年#{@date.month}月",@date],["#{@date.next_month.year}年#{@date.next_month.month}月",@date.next_month],["#{@date.next_month.next_month.year}年#{@date.next_month.next_month.month}月",@date.next_month.next_month]]
    @group = Group.find(params[:group_id])
    @rowspan = @group.shift_frames.count
    @shift_frames = @group.shift_frames
    @stores = @group.stores
    store_ids = @stores.ids
    group_staff_ids = Staff.where(store_id:store_ids)
    first_day = @date.beginning_of_month
    last_day = first_day.end_of_month
    @one_month = [*first_day..last_day]
    shifts = Shift.includes([:store,:fix_shift_pattern,:shift_pattern]).where(staff_id:group_staff_ids,date:@one_month)
    @shifts = shifts.map{|shift|[[shift.staff_id,shift.date],shift]}.to_h
    @staff_shinsei_count = shifts.where.not(shift_pattern_id: nil).group(:staff_id).count
    @staff_syukkin_count = shifts.where.not(fix_shift_pattern_id: nil).group(:staff_id).count
    staff_ids = shifts.map{|shift|shift.staff_id}.uniq
    # add_ids = group_staff_ids - shift_staff_ids
    # staff_ids =shift_staff_ids + add_ids
    @staffs = Staff.includes([:store]).where(id:staff_ids).order(row:'asc')

    @fix_shift_patterns = FixShiftPattern.where(group_id:@group.id)
    @shift_patterns = ShiftPattern.where(group_id:@group.id)

    @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    Shift.includes(fix_shift_pattern:[:shift_frames,fix_shift_pattern_shift_frames:[:shift_frame]]).where(date:@one_month).each do |shift|
      if shift.fix_shift_pattern_id.present?
        date = shift.date
        store_id = shift.store_id
        shift.fix_shift_pattern.shift_frames.each do |sf|
          if @hash[store_id][date][sf.id].present?
            @hash[store_id][date][sf.id] += 1
          else
            @hash[store_id][date][sf.id] = 1
          end
        end
      end
    end
  end
  def create_frame
    group = Group.find(params[:group_id])
    store_ids = group.stores.ids
    @date = Date.parse(params[:date])
    first_day = @date.beginning_of_month
    last_day = first_day.end_of_month
    @one_month = [*first_day..last_day]
    aaa = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    staff_ids = Staff.where(status:0,store_id:store_ids).ids
    Shift.where(date:@one_month,staff_id:staff_ids).each do |shift|
      if aaa[shift.date].present?
        aaa[shift.date] << shift.staff_id
      else
        aaa[shift.date] = [shift.staff_id]
      end
    end
    new_arr = []
    @one_month.each do |date|
      if aaa[date].present?
        created_staff_ids = aaa[date]
      else
        created_staff_ids = []
      end
      create_staff_ids = staff_ids - created_staff_ids
      create_staff_ids.each do |staff_id|
        new_arr << Shift.new(staff_id:staff_id,date:date)
      end
    end
    Shift.import new_arr
    redirect_to shifts_path(date:@date,group_id:params[:group_id]),notice:"#{@date.month}月のシフト枠を作成しました"
  end

  def index
    if params[:date]
      @date = Date.parse(params[:date])
    else
      @date = Date.today
    end
    @group = Group.find(params[:group_id])
    @shift_frames = @group.shift_frames
    @stores = @group.stores
    store_ids = @stores.ids
    group_staff_ids = Staff.where(store_id:store_ids)
    first_day = @date.beginning_of_month
    last_day = first_day.end_of_month
    @one_month = [*first_day..last_day]
    shifts = Shift.includes([:store,:fix_shift_pattern,:shift_pattern]).where(staff_id:group_staff_ids,date:@one_month)
    @shifts = shifts.map{|shift|[[shift.staff_id,shift.date],shift]}.to_h
    @staff_shinsei_count = shifts.where.not(shift_pattern_id: nil).group(:staff_id).count
    @staff_syukkin_count = shifts.where.not(fix_shift_pattern_id: nil).group(:staff_id).count
    shift_staff_ids = shifts.map{|shift|shift.staff_id}.uniq
    add_ids = group_staff_ids - shift_staff_ids
    staff_ids =shift_staff_ids + add_ids
    @staffs = Staff.includes([:store]).where(id:staff_ids).order(row:'asc')

    @fix_shift_patterns = FixShiftPattern.where(group_id:@group.id)
    @shift_patterns = ShiftPattern.where(group_id:@group.id)

    @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    Shift.includes(fix_shift_pattern:[:shift_frames,fix_shift_pattern_shift_frames:[:shift_frame]]).where(date:@one_month).each do |shift|
      if shift.fix_shift_pattern_id.present?
        date = shift.date
        store_id = shift.store_id
        shift.fix_shift_pattern.shift_frames.each do |sf|
          if @hash[store_id][date][sf.id].present?
            @hash[store_id][date][sf.id] += 1
          else
            @hash[store_id][date][sf.id] = 1
          end
        end
      end
    end
    @rowspan = @group.shift_frames.count
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "#{@date.year}_#{@date.month}_shift.csv", type: :csv
      end
    end
  end


  def jobcan_upload
    if params[:date]
      @date = Date.parse(params[:date])
    else
      @date = Date.today
    end
    first_day = @date.beginning_of_month
    last_day = first_day.end_of_month
    @one_month = [*first_day..last_day]
    @shifts = Shift.where(date:@one_month)
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "#{@date.year}_#{@date.month}_shift.csv", type: :csv
      end
    end
  end

  def show
  end

  def new
    @shift = Shift.new
  end

  def edit
  end

  def create
    @shift = Shift.new(shift_params)
    respond_to do |format|
      if @shift.save
        format.html { redirect_to @shift, notice: "Shift was successfully created." }
        format.js
      else
        format.html { render :new, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def update
    if params['shift']['admin_shinsei_edit_flag'] == 'true'
      @shinsei_flag = true
    end
    if @shift.fix_shift_pattern_id_was.present?
      before_fix_shift_pattern_id = @shift.fix_shift_pattern_id_was
      @before_fix_shift_pattern = FixShiftPattern.find(before_fix_shift_pattern_id)
      @before_shift_frames = @before_fix_shift_pattern.shift_frames
    end
    if @shift.store_id_was.present?
      @before_store_id = @shift.store_id_was
      @before_store = Store.find(@before_store_id)
    end
    respond_to do |format|
      if @shift.update(shift_params)
        if @shift.store_id.present?
          @store = @shift.store
        end
        if @shift.fix_shift_pattern.present?
          @shift_frames = @shift.fix_shift_pattern.shift_frames
        end
        format.html { redirect_to @shift, notice: "Shift was successfully updated." }
        format.js
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def destroy
    @shift.destroy
    respond_to do |format|
      format.html { redirect_to shifts_url, notice: "Shift was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_shift
      @shift = Shift.find(params[:id])
    end

    def shift_params
      params.require(:shift).permit(:date,:staff_id,:shift_pattern_id,:fix_shift_pattern_id,:memo,:store_id)
    end
end
