class TasksController < ApplicationController
  before_action :set_task, only: %i[ show edit update destroy ]
  def store
    if params[:date]
      @date = Date.parse(params[:date])
    else
      @date = Date.today
      params[:date]=@date
    end
    @store = Store.find(params[:store_id])
    @tasks = @store.tasks.where(action_date:@date).order(:action_time)
    @task = Task.new(store_id:params[:store_id],action_date:params[:date])
  end


  def index
    if params[:date]
      @date = Date.parse(params[:date])
    else
      @date = Date.today
      params[:date]=@date
    end
    @tasks = Task.where(action_date:@date)
    @task = Task.new
  end

  def show
  end

  def new
    @task = Task.new
  end

  def edit
  end

  def create
    @task = Task.new(task_params)
    if params['stores'].present?
      new_tasks_arr = []
      Store.where(id:params['stores'].keys).each do |store|
        new_task = Task.new(store_id:store.id,action_date:@task.action_date,action_time:@task.action_time,content:@task.content,memo:@task.memo,drafter:@task.drafter)
        new_tasks_arr << new_task
      end
      Task.import new_tasks_arr
    end
    respond_to do |format|
      if @task.save
        Task.chatwork_notice(@task,params['stores']) if params['chatwork_notice'].present?
        format.html { redirect_to store_tasks_path(store_id:@task.store_id,date:@task.action_date), notice: "Task was successfully created." }
        format.json { render :show, status: :created, location: @task }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @class_name = ".task_tr_#{@task.id}"

    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to store_tasks_path(store_id:@task.store_id,date:@task.action_date), notice: "Task was successfully updated." }
        format.json { render :show, status: :ok, location: @task }
        format.js
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
      params.require(:task).permit(:store_id,:task_template_id,:action_date,:action_time,:content,:memo,:status,:status_change_datetime,:drafter,:important_flag)
    end
end
