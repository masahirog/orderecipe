class TaskTemplatesController < ApplicationController
  before_action :set_task_template, only: %i[ show edit update destroy ]

  def hand_reflect
    date = Date.today
    new_tasks = []
    task_template = TaskTemplate.find(params[:task_template_id])
    task_template.stores.each do |store|
      task = Task.new(store_id:store.id,task_template_id:task_template.id,action_date:date,drafter:task_template.drafter,
        action_time:task_template.action_time,content:task_template.content,memo:task_template.memo,status:0)
      new_tasks << task
    end
    Task.import new_tasks
    redirect_to task_templates_path
  end
  def index
    @task_templates = TaskTemplate.all
  end

  def show
  end

  def new
    @task_template = TaskTemplate.new
  end

  def edit
  end

  def create
    @task_template = TaskTemplate.new(task_template_params)

    respond_to do |format|
      if @task_template.save
        format.html { redirect_to task_templates_path, notice: "Task template was successfully created." }
        format.json { render :show, status: :created, location: @task_template }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @task_template.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @task_template.update(task_template_params)
        format.html { redirect_to task_templates_path, notice: "Task template was successfully updated." }
        format.json { render :show, status: :ok, location: @task_template }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @task_template.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @task_template.destroy
    respond_to do |format|
      format.html { redirect_to task_templates_url, notice: "Task template was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_task_template
      @task_template = TaskTemplate.find(params[:id])
    end

    def task_template_params
      params.require(:task_template).permit(:repeat_type,:action_time,:content,:memo,:status,:drafter,
      task_template_stores_attributes: [:id, :store_id,:task_template_id])
    end
end
