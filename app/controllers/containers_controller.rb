class ContainersController < ApplicationController
  before_action :set_container, only: %i[ show edit update destroy ]

  def index
    @containers = Container.where(group_id:current_user.group_id)
  end

  def show
  end

  def new
    @container = Container.new(group_id:current_user.group_id)
  end

  def edit
  end

  def create
    @container = Container.new(container_params)

    respond_to do |format|
      if @container.save
        format.html { redirect_to containers_path, success: "OK！" }
        format.json { render :show, status: :created, location: @container }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @container.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @container.update(container_params)
        format.html { redirect_to containers_path, success: "OK！" }
        format.json { render :show, status: :ok, location: @container }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @container.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @container.destroy
    respond_to do |format|
      format.html { redirect_to containers_url, success: "OK！" }
      format.json { head :no_content }
    end
  end

  private
    def set_container
      @container = Container.find(params[:id])
    end

    def container_params
      params.require(:container).permit(:name,:group_id,:inversion_label_flag)
    end
end
