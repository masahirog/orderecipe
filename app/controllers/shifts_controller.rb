class ShiftsController < ApplicationController
  before_action :set_shift, only: %i[ show edit update destroy ]

  def index
    @date = Date.parse(params[:date])
    first_day = @date.beginning_of_month
    last_day = first_day.end_of_month
    @one_month = [*first_day..last_day]
    @shifts = Shift.where(date:@one_month).map{|shift|[[shift.staff_id,shift.date],shift]}.to_h
    @staffs = Staff.all
    @stores = Store.all
    @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    Shift.includes([:shift_pattern,:fix_shift_pattern]).where(date:@one_month).each do |shift|
      if shift.fix_shift_pattern_id.present?
        date = shift.date
        store_id = shift.fix_shift_pattern.store_id
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
      params.require(:shift).permit(:date,:staff_id,:shift_pattern_id,:fix_shift_pattern_id,:memo)
    end
end
