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
    stores = Store.where(group_id:current_user.group_id)
    if params[:staff_id].present?
      @staff = Staff.find(params[:staff_id])
      @tasks = Task.includes([:task_comments,:task_images,:task_staffs,task_stores:[:store]]).where(:task_staffs => {staff_id:params[:staff_id],read_flag:false}).where(group_id:current_user.group_id).rank(:row_order)
      @staffs = Staff.where(group_id:current_user.group_id,employment_status:1,status:0)
    elsif params[:store_id].present?
      @tasks = Task.joins(:task_stores).where(:task_stores => {store_id:params[:store_id],subject_flag:true}).includes([:task_comments,:task_images,task_stores:[:store]]).rank(:row_order)
      @staffs = Staff.joins(:staff_stores).where(:staff_stores => {store_id:params[:store_id]}).where(employment_status:1,status:0)
      # @staffs = Staff.where(store_id:params[:store_id]).where(employment_status:1,status:0)
    else
      @staffs = Staff.where(group_id:current_user.group_id,employment_status:1,status:0)
      @tasks = Task.where(group_id:current_user.group_id).includes([:task_comments,:task_images,task_stores:[:store]]).rank(:row_order)
    end
    @tasks.each do |task|
      stores.each do |store|
        task.task_stores.build(store_id:store.id)
      end
    end

    @task = Task.new(group_id:current_user.group_id)
    @todos = @tasks.where(status:0)
    @doings = @tasks.where(status:1)
    @hikitsugis = @tasks.where(status:6)
    @staff_shares = @tasks.where(status:5)
    @tasks = @tasks.includes(task_staffs:[:staff])
    @checks = @tasks.where(status:2)
    @dones = @tasks.where(status:3)
    @hash = {}
    @staffs.each do |staff|
      @hash[staff.id] = staff.task_staffs.where(read_flag:false,task_id:@checks.ids).count
      # @task.task_staffs.build(staff_id:staff.id,read_flag:false)
    end
    if params[:status].present?
      @archives = Task.where(status:4,group_id:current_user.group_id).rank(:row_order)
    end
    @stores_hash = {}
    stores.each do |store|
      @stores_hash[store.id]=store.name
      @task.task_stores.build(store_id:store.id)
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
    @stores_hash = {}
    Store.where(group_id:current_user.group_id).each do |store|
      @stores_hash[store.id]=store.name
    end
    task_created_staff_ids = []
    @task.task_stores.each do |ts|
      if ts.subject_flag == true
        ts.store.staffs.where(employment_status:1,status:0).each do|staff|
          @task.task_staffs.build(staff_id:staff.id,read_flag:false) unless task_created_staff_ids.include?(staff.id) 
          task_created_staff_ids << staff.id
        end
      end
    end
    respond_to do |format|
      if @task.save
        if params[:task]["slack_notify"]=="1"
          message = "新規のプロジェクト・タスクが追加されました！\n"+
          "リストの確認をお願いします。\n"+
          "https://bento-orderecipe.herokuapp.com/tasks?group_id=#{@task.group_id}&task_id=#{@task.id}\n"+
          "投稿者：#{@task.drafter}\n"+
          "タイトル：#{@task.title}\n"+
          "内容：#{@task.content}"

          attachment_images =[]
          @task.task_images.each do |ti|
            attachment_images << {image_url: ti.image.url}
          end
          stores = Store.where(id:@task.task_stores.where(subject_flag:true).map{|ts|ts.store_id})
          slack_urls = stores.map{|store|store.task_slack_url}.uniq
          slack_urls.each do |slack_url|
            Slack::Notifier.new(slack_url, username: 'Bot', icon_emoji: ':male-farmer:', attachments: attachment_images).ping(message)
          end
          # if @task.group.task_slack_url.present?
            # Slack::Notifier.new(@task.group.task_slack_url, username: 'Bot', icon_emoji: ':male-farmer:', attachments: attachment_images).ping(message)
          # end
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
    @stores_hash = {}
    Store.where(group_id:current_user.group_id).each do |store|
      @stores_hash[store.id]=store.name
    end
    respond_to do |format|
      if @task.update(task_params)
        if params[:task]["slack_notify"]=="1"
          message = "新規のプロジェクト・タスクが追加されました！\n"+
          "リストの確認をお願いします。\n"+
          "https://bento-orderecipe.herokuapp.com/tasks?group_id=#{@task.group_id}&task_id=#{@task.id}\n"+
          "投稿者：#{@task.drafter}\n"+
          "タイトル：#{@task.title}\n"+
          "内容：#{@task.content}"

          attachment_images =[]
          @task.task_images.each do |ti|
            attachment_images << {image_url: ti.image.url}
          end
          stores = Store.where(id:@task.task_stores.where(subject_flag:true).map{|ts|ts.store_id})
          slack_urls = stores.map{|store|store.task_slack_url}.uniq
          slack_urls.each do |slack_url|
            Slack::Notifier.new(slack_url, username: 'Bot', icon_emoji: ':male-farmer:', attachments: attachment_images).ping(message)
          end
          # if @task.group.task_slack_url.present?
            # Slack::Notifier.new(@task.group.task_slack_url, username: 'Bot', icon_emoji: ':male-farmer:', attachments: attachment_images).ping(message)
          # end
        end

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
        task_images_attributes:[:id,:task_id,:image,:image_cache,:_destroy,:remove_image],
        task_stores_attributes:[:id,:store_id,:task_id,:subject_flag])
    end
end
