class TaskStaffsController < ApplicationController
  before_action :set_task_staff, only: %i[ show edit update destroy ]

  def index
    @task_staffs = TaskStaff.all
  end

  def show
  end

  def new
    @task_staff = TaskStaff.new
  end

  def edit
  end

  def create
    @task_staff = TaskStaff.new(task_staff_params)
    respond_to do |format|
      if @task_staff.save
        format.html { redirect_to task_staff_url(@task_staff), notice: "Task staff was successfully created." }
        format.json { render :show, status: :created, location: @task_staff }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @task_staff.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @task = @task_staff.task
    respond_to do |format|
      if @task_staff.update(task_staff_params)
        @count = @task.task_staffs.where(read_flag:true).count
        format.html { redirect_to task_staff_url(@task_staff), notice: "Task staff was successfully updated." }
        format.js
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.js { render :errors }
      end
    end
  end

  def destroy
    @task_staff.destroy

    respond_to do |format|
      format.html { redirect_to task_staffs_url, notice: "Task staff was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_task_staff
      @task_staff = TaskStaff.find(params[:id])
    end

    def task_staff_params
      params.require(:task_staff).permit(:read_flag,:staff_id,:task_id)
    end
end
