class TasksController < ApplicationController
  protect_from_forgery except: :sort
  before_action :set_task, only: %i[ show edit update destroy ]
  def sort
    task = Task.find(params[:task_id])
    task.update(task_params)
    render body: nil
  end
  def index
    if params[:task_id].present?
      gon.task_id = params[:task_id]
    else
      gon.task_id = ''
    end
    group_id = params[:group_id]
    if params[:staff_id].present?
      @staff = Staff.find(params[:staff_id])
      @tasks = Task.includes([:task_comments,:task_images,:task_staffs]).where(:task_staffs => {staff_id:params[:staff_id],read_flag:false}).where(group_id:group_id).rank(:row_order)
      # @tasks = Task.includes([:task_comments,:task_images,:task_staffs]).rank(:row_order)
    else
      @tasks = Task.where(group_id:group_id).includes([:task_comments,:task_images]).rank(:row_order)
    end
    @task = Task.new(group_id:group_id)
    @todos = @tasks.where(status:0)
    @doings = @tasks.where(status:1)
    @hikitsugis = @tasks.where(status:6)
    @staff_shares = @tasks.where(status:5)
    @tasks = @tasks.includes(task_staffs:[:staff])
    @checks = @tasks.where(status:2)
    @dones = @tasks.where(status:3)
    @staffs = Staff.joins(:store).where(:stores => {group_id:group_id}).where(employment_status:1,status:0)
    @hash = {}
    @staffs.each do |staff|
      @hash[staff.id] = staff.task_staffs.where(read_flag:false,task_id:@checks.ids).count
      @task.task_staffs.build(staff_id:staff.id,read_flag:false)
    end

    if params[:status].present?
      @archives = Task.where(status:4,group_id:group_id).rank(:row_order)
    end
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
    respond_to do |format|
      if @task.save
        if params["chatwork_notice"]=='true'
          message = "新規のプロジェクト・タスクが追加されました！\n"+
          "リストの確認をお願いします。\n"+
          "https://bejihan-orderecipe.herokuapp.com/tasks?group_id=#{@task.group_id}&task_id=#{@task.id}\n"+
          "投稿者：#{@task.drafter}\n"+
          "タイトル：#{@task.title}\n"+
          "内容：#{@task.content}"

          attachment_images =[]
          @task.task_images.each do |ti|
            attachment_images << {image_url: ti.image.url}
          end

          if @task.group_id == 9
            Slack::Notifier.new("https://hooks.slack.com/services/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", username: 'Bot', icon_emoji: ':male-farmer:', attachments: attachment_images).ping(message)
          else
            Slack::Notifier.new("https://hooks.slack.com/services/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", username: 'Bot', icon_emoji: ':male-farmer:', attachments: attachment_images).ping(message)
          end
        end
        format.html { redirect_to tasks_path(group_id:@task.group_id), success: "タスクを1件作成しました。" }
        format.js
      else
        format.html { render :new, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to tasks_path(group_id:@task.group_id), success: "タスクを1件更新しました。" }
        format.js
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def destroy
    @task.destroy

    respond_to do |format|
      format.html { redirect_to tasks_path(group_id:@task.group_id), notice: "Task was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_task
      @task = Task.find(params[:id])
    end

    def task_params
      params.require(:task).permit(:title,:content,:status,:drafter,:final_decision,:row_order_position,:category,:group_id,:part_staffs_share_flag,
        task_staffs_attributes:[:id,:task_id,:staff_id,:read_flag,:_destroy],
        task_images_attributes:[:id,:task_id,:image,:image_cache,:_destroy,:remove_image])
    end
end
