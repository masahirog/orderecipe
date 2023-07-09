class ShiftsController < ApplicationController
  before_action :set_shift, only: %i[ show edit update destroy ]
  def csv_once_update
    Shift.upload_data(params[:file])
    redirect_to shifts_path(date:params[:date],group_id:params[:group_id],store_type:params[:store_type]), :success => "一括更新しました"
  end

  def transportation_expenses
     @group = Group.find(params[:group_id])
    if params[:store_type].present?
      @store_type = params[:store_type]
      @stores = @group.stores.includes(:fix_shift_pattern_stores,store_shift_frames:[:shift_frame]).where(store_type:@store_type)
    else
      @store_type = nil
      @stores = @group.stores.includes(:fix_shift_pattern_stores,store_shift_frames:[:shift_frame])
    end

    if params[:date]
      @date = Date.parse(params[:date])
    else
      @date = Date.today
    end
    @date =  Date.new(@date.prev_month.year,@date.prev_month.month,16) if @date.day < 15
    @year_months = [["#{@date.year}年#{@date.month}月",@date],["#{@date.next_month.year}年#{@date.next_month.month}月",@date.next_month],["#{@date.next_month.next_month.year}年#{@date.next_month.next_month.month}月",@date.next_month.next_month]]
    @shift_frames = @group.shift_frames
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
    @staffs = Staff.includes(:stores,staff_stores:[:store]).where(id:staff_ids,status:0).order(row:'asc')
    first_day = Date.new(@date.year,@date.month, 16)
    last_day = first_day.end_of_month
    last_day = Date.new((last_day + 1).year,(last_day +1).month, 15)
    @one_month = [*first_day..last_day]
    @shifts = Shift.includes(:store,:shift_pattern).where(staff_id:@staffs.ids,date:@one_month)

    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "transportation_expenses_#{@date.year}_#{@date.month}.csv", type: :csv
      end
    end
  end
  def get_fix_shift_pattern
    @fix_shift_patterns = FixShiftPattern.all
  end
  def reflect_default_shifts
    group = Group.find(params[:group_id])
    if params[:store_type].present?
      @store_type = params[:store_type]
      @stores = group.stores.where(store_type:@store_type)
    else
      @store_type = nil
      @stores = group.stores
    end
    if params[:stores]
      @stores = Store.where(id:params['stores'].keys)
    else
      params[:stores] = {}
      @stores.each do |store|
        params[:stores][store.id.to_s] = true
      end
    end

    @date = Date.parse(params[:date])
    @date = Date.new(@date.prev_month.year,@date.prev_month.month,16) if @date.day < 15
    first_day = Date.new(@date.year,@date.month, 16)
    last_day = first_day.end_of_month
    last_day = Date.new((last_day + 1).year,(last_day +1).month, 15)
    @one_month = [*first_day..last_day]

    staff_ids = @stores.map{|store|store.staffs.ids}.flatten.uniq
    @staffs = Staff.where(id:staff_ids,status:0)
    default_shift_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    DefaultShift.where(staff_id:@staffs.ids).each do |default_shift|
      default_shift_hash[default_shift.staff_id][default_shift.weekday] = default_shift
    end
    update_shifts = []
    Shift.where(date:@one_month,staff_id:@staffs.ids).each do |shift|
      wday = shift.date.wday
      default_shift = default_shift_hash[shift.staff_id][wday]
      if default_shift.present?
        shift.store_id = default_shift.store_id
        shift.fix_shift_pattern = default_shift.fix_shift_pattern
        shift.start_time = default_shift.start_time
        shift.end_time = default_shift.end_time
      end
      update_shifts << shift
    end
    Shift.import update_shifts, on_duplicate_key_update:[:store_id,:fix_shift_pattern_id,:start_time,:end_time]
    redirect_to shifts_path(date:@date,group_id:params[:group_id],store_type:@store_type),success:"デフォルトのシフトを反映しました。"

  end

  def once_update
    staff = Staff.find(params[:staff_id])
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
    redirect_to shifts_path(date:date,group_id:staff.group_id),:notice => "シフトを申請しました。"
  end
  def staff_edit
    staff_id = params[:staff_id]
    @staff = Staff.find(staff_id)
    date = params[:date]
    if staff_id.present? && date.present?

      @date = Date.parse(params[:date])
      @date = Date.new(@date.prev_month.year,@date.prev_month.month,16) if @date.day < 15
      first_day = Date.new(@date.year,@date.month, 16)
      last_day = first_day.end_of_month
      last_day = Date.new((last_day + 1).year,(last_day +1).month, 15)

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

  def create_frame
    group = Group.find(params[:group_id])
    # store_ids = group.stores.ids
    @date = Date.parse(params[:date])
    @date = Date.new(@date.prev_month.year,@date.prev_month.month,16) if @date.day < 15
    first_day = Date.new(@date.year,@date.month, 16)
    last_day = first_day.end_of_month
    last_day = Date.new((last_day + 1).year,(last_day +1).month, 15)

    # first_day = @date.beginning_of_month
    # last_day = first_day.end_of_month
    @one_month = [*first_day..last_day]
    if params[:store_type].present?
      @store_type = params[:store_type]
      @stores = group.stores.where(store_type:@store_type)
    else
      @store_type = nil
      @stores = group.stores
    end
    if params[:stores]
      @stores = Store.where(id:params['stores'].keys)
    else
      params[:stores] = {}
      @stores.each do |store|
        params[:stores][store.id.to_s] = true
      end
    end

    staff_ids = @stores.map{|store|store.staffs.ids}.flatten.uniq

    hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    Shift.where(date:@one_month,staff_id:staff_ids).each do |shift|
      if hash[shift.date].present?
        hash[shift.date] << shift.staff_id
      else
        hash[shift.date] = [shift.staff_id]
      end
    end
    new_arr = []
    @one_month.each do |date|
      if hash[date].present?
        created_staff_ids = hash[date]
      else
        created_staff_ids = []
      end
      create_staff_ids = staff_ids - created_staff_ids
      create_staff_ids.each do |staff_id|
        new_arr << Shift.new(staff_id:staff_id,date:date)
      end
    end
    Shift.import new_arr
    redirect_to shifts_path(date:@date,group_id:params[:group_id],store_type:@store_type),success:"#{@date.month}月のシフト枠を作成しました"
  end
  def fixed
    if params[:date]
      @date = Date.parse(params[:date])
    else
      @date = Date.today
    end
    @group = Group.find(params[:group_id])

    @shift_frames = @group.shift_frames
    @stores = @group.stores
    if params[:stores]
      @checked_stores = Store.where(id:params['stores'].keys)
    else
      @checked_stores = @stores
      params[:stores] = {}
      @stores.each do |store|
        params[:stores][store.id.to_s] = true
      end
    end
    staff_ids = @checked_stores.map{|store|store.staff_ids}.flatten.uniq
    @staffs = Staff.where(id:staff_ids,status:0)
    # group_staff_ids = Staff.where(group_id:@group.id,status:0)
    # first_day = @date.beginning_of_month
    first_day = Date.new(@date.year,@date.month, 16)
    last_day = first_day.end_of_month
    last_day = Date.new((last_day + 1).year,(last_day +1).month, 15)
    @one_month = [*first_day..last_day]
    shifts = Shift.where(staff_id:@staffs.ids,date:@one_month)
    @shifts = shifts.map{|shift|[[shift.staff_id,shift.date],shift]}.to_h
    shift_staff_ids = shifts.map{|shift|shift.staff_id}.uniq
    # add_ids = staff_ids - shift_staff_ids
    # staff_ids =shift_staff_ids + add_ids
    # @staffs = Staff.where(id:staff_ids).order(row:'asc')
    @shifts_fixed_hash = shifts.map{|shift|[shift.id,shift.fixed_flag]}.to_h
  end

  def once_update_fixed
    if params[:date].present?
      @date = Date.parse(params[:date])
    else
      @date = Date.today
    end
    @group = Group.find(params[:group_id])

    @shift_frames = @group.shift_frames
    @stores = @group.stores
    if params[:stores]
      @checked_stores = Store.where(id:params['stores'].keys)
    else
      @checked_stores = @stores
      params[:stores] = {}
      @stores.each do |store|
        params[:stores][store.id.to_s] = true
      end
    end
    staff_ids = @checked_stores.map{|store|store.staff_ids}.flatten.uniq
    first_day = Date.new(@date.year,@date.month, 16)
    last_day = first_day.end_of_month
    last_day = Date.new((last_day + 1).year,(last_day +1).month, 15)
    @one_month = [*first_day..last_day]
    @stores = @group.stores.where.not(id:39)
    staff_ids = Staff.where(id:staff_ids,status:0)
    shifts = Shift.where(staff_id:staff_ids,date:@one_month)
    fixed_shift_ids = []
    if params['shifts'].present?
      fixed_shift_ids = params["shifts"].keys.map(&:to_i)
      fixed_shifts = Shift.where(id:fixed_shift_ids)
      fixed_shifts.update_all(fixed_flag:true)
    end
    un_fixed_shift_ids = shifts.ids - fixed_shift_ids
    Shift.where(id:un_fixed_shift_ids).update_all(fixed_flag:false) if un_fixed_shift_ids.present?
    redirect_to shifts_path(group_id:params[:group_id],date:@date,stores:params[:stores].to_unsafe_h), notice: "公開ステータスを更新しました！" 
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

    if params[:date]
      @date = Date.parse(params[:date])
    else
      @date = Date.today
    end
    @date =  Date.new(@date.prev_month.year,@date.prev_month.month,16) if @date.day < 15
    @year_months = [["#{@date.year}年#{@date.month}月16日〜",@date],["#{@date.next_month.year}年#{@date.next_month.month}月16日〜",@date.next_month],["#{@date.next_month.next_month.year}年#{@date.next_month.next_month.month}月16日〜",@date.next_month.next_month]]
    @shift_frames = @group.shift_frames
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
    
    first_day = Date.new(@date.year,@date.month, 16)
    last_day = first_day.end_of_month
    last_day = Date.new((last_day + 1).year,(last_day +1).month, 15)
    @one_month = [*first_day..last_day]
    shifts = Shift.includes(:store,:shift_pattern).where(staff_id:staff_ids,date:@one_month)
    @shifts = shifts.map{|shift|[[shift.staff_id,shift.date],shift]}.to_h
    @staff_shinsei_count = shifts.where.not(shift_pattern_id: nil).group(:staff_id).count
    @staff_syukkin_count = shifts.joins(:fix_shift_pattern).where.not(:fix_shift_patterns=>{working_hour:0}).where.not(fix_shift_pattern_id: nil).group(:staff_id).count
    @date_store_working_count = shifts.joins(:fix_shift_pattern).where.not(:fix_shift_patterns=>{working_hour:0}).where.not(fix_shift_pattern_id: nil).group(:date,:store_id).count
    @staff_working_hour = shifts.joins(:fix_shift_pattern).where.not(:fix_shift_patterns=>{working_hour:0}).where.not(fix_shift_pattern_id: nil).group(:staff_id).sum("fix_shift_patterns.working_hour")
    @date_store_working_hour = shifts.joins(:fix_shift_pattern).where.not(:fix_shift_patterns=>{working_hour:0}).where.not(fix_shift_pattern_id: nil).group(:date,:store_id).sum("fix_shift_patterns.working_hour")
    shift_staff_ids = shifts.map{|shift|shift.staff_id}.uniq
    add_ids = staff_ids - shift_staff_ids
    staff_ids =shift_staff_ids + add_ids
    @staffs = Staff.includes(:stores,staff_stores:[:store]).where(id:staff_ids,status:0).order(row:'asc')
    @select_option_stores = Store.joins(:staff_stores).where(:staff_stores => {staff_id:@staffs.ids}).uniq
    shift_frame_ids = ShiftFrame.joins(:store_shift_frames).where(:store_shift_frames => {id:@stores.ids}).ids.uniq
    # fix_shift_patterns = FixShiftPattern.where(group_id:@group.id).order(:pattern_name)
    @store_fix_shift_patterns_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    FixShiftPatternStore.includes(:fix_shift_pattern).where(store_id:@select_option_stores.map{|store|store.id}).each do |fsps|
      @store_fix_shift_patterns_hash[fsps.store_id][fsps.fix_shift_pattern.pattern_name] = fsps.fix_shift_pattern if fsps.fix_shift_pattern.unused_flag == false
    end
    @store_fix_shift_patterns_hash.each do |key, value|
      @store_fix_shift_patterns_hash[key] = value.sort{ |a,b| a[0]<=>b[0] }
    end
    @shift_patterns = ShiftPattern.where(group_id:@group.id)

    @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    Shift.includes(fix_shift_pattern:[:shift_frames,fix_shift_pattern_shift_frames:[:shift_frame]]).where(date:@one_month).each do |shift|
      if shift.fix_shift_pattern_id.present?
        date = shift.date
        store_id = shift.store_id
        working_hour = shift.fix_shift_pattern.working_hour
        shift.fix_shift_pattern.shift_frames.each do |sf|
          if @hash[store_id][date][sf.id].present?
            @hash[store_id][date][sf.id]['working_number'] += 1
            @hash[store_id][date][sf.id]['working_hour'] += working_hour
          else
            @hash[store_id][date][sf.id]['working_number'] = 1
            @hash[store_id][date][sf.id]['working_hour'] = working_hour
          end
        end
      end
    end
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "#{@date.year}_#{@date.month}_shift.csv", type: :csv
      end
    end
  end

  def download_mf_csv
    @shifts = Shift.where(id:params["shifts"].keys)
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "mf_shifts.csv", type: :csv
      end
    end
  end

  def mf
    if params[:date]
      @date = Date.parse(params[:date])
    else
      @date = Date.today
    end
    @group = Group.find(params[:group_id])

    @shift_frames = @group.shift_frames
    @stores = @group.stores
    if params[:stores]
      @checked_stores = Store.where(id:params['stores'].keys)
    else
      @checked_stores = @stores
      params[:stores] = {}
      @stores.each do |store|
        params[:stores][store.id.to_s] = true
      end
    end
    staff_ids = @checked_stores.map{|store|store.staff_ids}.flatten.uniq
    @staffs = Staff.where(id:staff_ids,status:0)
    first_day = Date.new(@date.year,@date.month, 16)
    last_day = first_day.end_of_month
    last_day = Date.new((last_day + 1).year,(last_day +1).month, 15)
    @one_month = [*first_day..last_day]
    shifts = Shift.where(staff_id:@staffs.ids,date:@one_month)
    @shifts = shifts.map{|shift|[[shift.staff_id,shift.date],shift]}.to_h
    shift_staff_ids = shifts.map{|shift|shift.staff_id}.uniq
    @shifts_fixed_hash = shifts.map{|shift|[shift.id,shift.fixed_flag]}.to_h
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
    if @shift.fix_shift_pattern_id_was.present?
      before_fix_shift_pattern_id = @shift.fix_shift_pattern_id_was
      @before_fix_shift_pattern = FixShiftPattern.find(before_fix_shift_pattern_id)
      @before_shift_frames = @before_fix_shift_pattern.shift_frames
    end
    if @shift.store_id_was.present?
      @before_store_id = @shift.store_id_was
      @before_store = Store.find(@before_store_id)
    end
    if @shift.store_id_was == params[:shift][:store_id].to_i
    else
      @store_change_flag = true
      params[:shift][:fix_shift_pattern_id]=""
    end
    if params[:shift][:store_id].present?
      store = Store.find(params[:shift][:store_id])
      @fix_shift_patterns = store.fix_shift_patterns.where(unused_flag:false).order(:pattern_name)
    else
      @fix_shift_patterns = []
    end
    if params[:shift][:fix_shift_pattern_id].present?
      fix_shift_pattern = FixShiftPattern.find(params[:shift][:fix_shift_pattern_id])
      if fix_shift_pattern.start_time.present?
        params[:shift][:start_time]= fix_shift_pattern.start_time
      else
        params[:shift][:start_time]=nil
      end
      if fix_shift_pattern.end_time.present?
        params[:shift][:end_time]=fix_shift_pattern.end_time
      else
        params[:shift][:end_time]=nil
      end
    else
      params[:shift][:start_time]=nil
      params[:shift][:end_time]=nil
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
      params.require(:shift).permit(:date,:staff_id,:shift_pattern_id,:fix_shift_pattern_id,:memo,:store_id,:start_time,:end_time)
    end
end
