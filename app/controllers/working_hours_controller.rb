class WorkingHoursController < ApplicationController
  before_action :set_working_hour, only: %i[ show edit update destroy ]

  def index
    @working_hours = WorkingHour.all
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
    respond_to do |format|
      if @working_hour.update(working_hour_params)
        format.html { redirect_to working_hour_url(@working_hour), notice: "Working hour was successfully updated." }
        format.json { render :show, status: :ok, location: @working_hour }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @working_hour.errors, status: :unprocessable_entity }
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
      params.require(:working_hour).permit(:date,:name,:working_time,:jobcan_staff_code,:store_id)
    end
end
