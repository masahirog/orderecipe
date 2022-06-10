class TasksController < ApplicationController
  protect_from_forgery except: :sort
  before_action :set_task, only: %i[ show edit update destroy ]
  def sort
    task = Task.find(params[:task_id])
    task.update(task_params)
    render body: nil
  end

  def index
    @tasks = Task.includes([:task_comments]).rank(:row_order)
    @todos = @tasks.where(status:0)
    @doings = @tasks.where(status:1)
    @tasks = @tasks.includes(task_staffs:[:staff])
    @checkings = @tasks.where(status:2)
    @dones = @tasks.where(status:3)
  end

  def show
  end

  def new
    @task = Task.new
    Staff.where(employment_status:1).where.not(store_id:39).each do |staff|
      @task.task_staffs.build(staff_id:staff.id,read_flag:false)
    end
  end

  def edit
  end

  def create
    @task = Task.new(task_params)
    respond_to do |format|
      if @task.save
        NotificationMailer.task_create_send_mail(@task).deliver
        format.html { redirect_to tasks_path, notice: "タスクを1件作成しました。" }
        format.json { render :show, status: :created, location: @task }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to tasks_path, notice: "タスクを1件更新しました。" }
        format.json { render :show, status: :ok, location: @task }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @task.destroy

    respond_to do |format|
      format.html { redirect_to tasks_url, notice: "Task was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_task
      @task = Task.find(params[:id])
    end

    def task_params
      params.require(:task).permit(:title,:content,:status,:drafter,:final_decision,:row_order_position,task_staffs_attributes:[:id,:task_id,:staff_id,:read_flag,:_destroy])
    end
end
