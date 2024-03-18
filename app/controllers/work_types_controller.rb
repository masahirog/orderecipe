class WorkTypesController < ApplicationController
  before_action :set_work_type, only: %i[ show edit update destroy ]

  def index
    @work_types = WorkType.all
  end

  def show
  end

  def new
    @work_type = WorkType.new(group_id:current_user.group_id)
  end

  def edit
  end

  def create
    @work_type = WorkType.new(work_type_params)

    respond_to do |format|
      if @work_type.save
        format.html { redirect_to work_type_url(@work_type), notice: "Work type was successfully created." }
        format.json { render :show, status: :created, location: @work_type }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @work_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @work_type.update(work_type_params)
        format.html { redirect_to work_type_url(@work_type), notice: "Work type was successfully updated." }
        format.json { render :show, status: :ok, location: @work_type }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @work_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @work_type.destroy

    respond_to do |format|
      format.html { redirect_to work_types_url, notice: "Work type was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_work_type
      @work_type = WorkType.find(params[:id])
    end

    def work_type_params
      params.require(:work_type).permit(:id,:name,:group_id)
    end
end
