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
        format.html { redirect_to tasks_path, notice: "コメント投稿" }
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
      format.json { head :no_content }
    end
  end

  private
    def set_task_comment
      @task_comment = TaskComment.find(params[:id])
    end

    def task_comment_params
      params.require(:task_comment).permit(:content,:name,:task_id)
    end
end
