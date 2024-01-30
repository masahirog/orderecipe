class BuppanSchedulesController < ApplicationController
  before_action :set_buppan_schedule, only: %i[ show edit update destroy ]

  def index
    @buppan_schedules = BuppanSchedule.all
  end

  def show
  end

  def new
    @buppan_schedule = BuppanSchedule.new
  end

  def edit
  end

  def create
    @buppan_schedule = BuppanSchedule.new(buppan_schedule_params)

    respond_to do |format|
      if @buppan_schedule.save
        format.html { redirect_to daily_items_path(date:@buppan_schedule.date), success: "更新しました。" }
        format.json { render :show, status: :created, location: @buppan_schedule }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @buppan_schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @buppan_schedule.update(buppan_schedule_params)
        format.html { redirect_to daily_items_path(date:@buppan_schedule.date), success: "更新しました。" }
        format.json { render :show, status: :ok, location: @buppan_schedule }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @buppan_schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @buppan_schedule.destroy

    respond_to do |format|
      format.html { redirect_to buppan_schedules_url, danger: "Buppan schedule was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_buppan_schedule
      @buppan_schedule = BuppanSchedule.find(params[:id])
    end

    def buppan_schedule_params
      params.require(:buppan_schedule).permit(:date,:fixed_flag,:memo)
    end
end
