class ShiftsController < ApplicationController
  before_action :set_shift, only: %i[ show edit update destroy ]

  def staff_edit
    @date = Date.parse(params[:date])
    first_day = @date.beginning_of_month
    last_day = first_day.end_of_month
    @one_month = [*first_day..last_day]
  end

  def check
    @date = Date.parse(params[:date])
    first_day = @date.beginning_of_month
    last_day = first_day.end_of_month
    @one_month = [*first_day..last_day]
    @year_months = [["#{@date.year}年#{@date.month}月",@date],["#{@date.next_month.year}年#{@date.next_month.month}月",@date.next_month],["#{@date.next_month.next_month.year}年#{@date.next_month.next_month.month}月",@date.next_month.next_month]]
    @shifts = Shift.where(date:@one_month).map{|shift|[[shift.staff_id,shift.date],shift]}.to_h
    @staffs = Staff.includes([:store]).all.order(row:'asc')
    @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    Shift.includes([:store,:shift_pattern,:fix_shift_pattern]).where(date:@one_month).each do |shift|
      if shift.fix_shift_pattern_id.present?
        date = shift.date
        store_id = shift.store_id
        section = shift.fix_shift_pattern.section
        if section == 2
          if @hash[store_id][date][0].present?
            @hash[store_id][date][0] += 1
          else
            @hash[store_id][date][0] = 1
          end
          if @hash[store_id][date][1].present?
            @hash[store_id][date][1] += 1
          else
            @hash[store_id][date][1] = 1
          end

        else
          if @hash[store_id][date][section].present?
            @hash[store_id][date][section] += 1
          else
            @hash[store_id][date][section] = 1
          end
        end
      end
    end
  end
  def create_frame
    @date = Date.parse(params[:date])
    first_day = @date.beginning_of_month
    last_day = first_day.end_of_month
    @one_month = [*first_day..last_day]
    aaa = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    staff_ids = Staff.ids
    Shift.where(date:@one_month).each do |shift|
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
    redirect_to shifts_path(date:@date),notice:"#{@date.month}月のシフト枠を作成しました"
  end

  def index
    @date = Date.parse(params[:date])
    first_day = @date.beginning_of_month
    last_day = first_day.end_of_month
    @one_month = [*first_day..last_day]
    shifts = Shift.where(date:@one_month)
    @shifts = shifts.map{|shift|[[shift.staff_id,shift.date],shift]}.to_h
    @staff_shinsei_count = shifts.where.not(shift_pattern_id: nil).group(:staff_id).count
    @staff_syukkin_count = shifts.where.not(fix_shift_pattern_id: nil).group(:staff_id).count
    @staffs = Staff.includes([:store]).all.order(row:'asc')
    @stores = Store.all
    @fix_shift_patterns = FixShiftPattern.all.order(section:'asc')
    @shift_patterns = ShiftPattern.all

    @options = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    FixShiftPattern.all.each do |fsp|
      if @options[fsp.section].present?
        @options[fsp.section] << [fsp.pattern_name,fsp.id]
      else
        @options[fsp.section] = [[fsp.pattern_name,fsp.id]]
      end
    end

    @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    Shift.includes([:shift_pattern,:fix_shift_pattern]).where(date:@one_month).each do |shift|
      if shift.fix_shift_pattern_id.present?
        date = shift.date
        store_id = shift.store_id
        section = shift.fix_shift_pattern.read_attribute_before_type_cast(:section)
        if section == 2
          if @hash[store_id][date][0].present?
            @hash[store_id][date][0] += 1
          else
            @hash[store_id][date][0] = 1
          end
          if @hash[store_id][date][1].present?
            @hash[store_id][date][1] += 1
          else
            @hash[store_id][date][1] = 1
          end

        else
          if @hash[store_id][date][section].present?
            @hash[store_id][date][section] += 1
          else
            @hash[store_id][date][section] = 1
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
    end
    if @shift.store_id_was.present?
      @before_store_id = @shift.store_id_was
      @before_store = Store.find(@before_store_id)
    end

    respond_to do |format|
      if @shift.update(shift_params)
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
