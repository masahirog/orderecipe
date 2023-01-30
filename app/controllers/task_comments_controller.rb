class TaskCommentsController < ApplicationController
  before_action :set_task_comment, only: %i[ show edit update destroy ]

  def index
    @task_comments = TaskComment.all
  end

  def show
  end

  def new
    @task_comment = TaskComment.new
  end

  def edit
  end

  def create
    @task_comment = TaskComment.new(task_comment_params)
    @task = @task_comment.task
    respond_to do |format|
      if @task_comment.save
        message = "https://bejihan-orderecipe.herokuapp.com/tasks?group_id=#{@task.group_id}&task_id=#{@task.id}\n"+
        "タスク名：#{@task.title}\n"+
        "ーー\n"+
        "コメント：#{@task_comment.content}"+
        "投稿：#{@task_comment.name}\n"+
        "ーー"
        attachment_image = {
          image_url: @task_comment.image.url
        }
        if @task.group_id == 9
          Slack::Notifier.new("https://hooks.slack.com/services/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", username: 'Bot', icon_emoji: ':male-farmer:', attachments: [attachment_image]).ping(message)
        else
          Slack::Notifier.new("https://hooks.slack.com/services/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", username: 'Bot', icon_emoji: ':male-farmer:', attachments: [attachment_image]).ping(message)
        end
        format.html { redirect_to tasks_path, success: "コメント投稿" }
        format.js
      else
        format.html { render :new, status: :unprocessable_entity }
        format.js { render :errors }
      end
    end
  end

  def update
    respond_to do |format|
      if @task_comment.update(task_comment_params)
        format.html { redirect_to task_comment_url(@task_comment), notice: "Task comment was successfully updated." }
        format.json { render :show, status: :ok, location: @task_comment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @task_comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @task_comment.destroy
    respond_to do |format|
      format.html { redirect_to task_comments_url, notice: "Task comment was successfully destroyed." }
      format.js
    end
  end

  private
    def set_task_comment
      @task_comment = TaskComment.find(params[:id])
    end

    def task_comment_params
      params.require(:task_comment).permit(:content,:name,:task_id,:image,:image_cache,:remove_image)
    end
end
