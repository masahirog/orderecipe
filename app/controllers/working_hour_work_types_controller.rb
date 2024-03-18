class WorkingHourWorkTypesController < ApplicationController
  before_action :set_working_hour_work_type, only: %i[ show edit update destroy ]

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
    @working_hour_work_type = WorkingHourWorkType.new(working_hour_work_type_params)

    respond_to do |format|
      if @working_hour_work_type.save
        format.html { redirect_to working_hour_work_type_url(@working_hour_work_type), notice: "Working hour work type was successfully created." }
        format.js
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @working_hour_work_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @working_hour_work_type.update(working_hour_work_type_params)
        format.html { redirect_to working_hour_work_type_url(@working_hour_work_type), notice: "Working hour work type was successfully updated." }
        format.js
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @working_hour_work_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @working_hour_work_type.destroy

    respond_to do |format|
      format.html { redirect_to working_hour_work_types_url, notice: "Working hour work type was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_working_hour_work_type
      @working_hour_work_type = WorkingHourWorkType.find(params[:id])
    end

    def working_hour_work_type_params
      params.require(:working_hour_work_type).permit(:id,:working_hour_id,:work_type_id,:time_frame)
    end
end
