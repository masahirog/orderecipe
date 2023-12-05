class ManualDirectoriesController < ApplicationController
  before_action :set_manual_directory, only: %i[ show edit update destroy ]

  def index
    @parent_manual_directories = ManualDirectory.where(ancestry:nil)
  end

  def show
    @parent_manual_directories = ManualDirectory.where(ancestry:nil)
  end

  def new
    @parent_manual_directories = ManualDirectory.where(ancestry:nil)
    @parent_manual_directory = ManualDirectory.find(params[:parent_manual_directory_id]) if params[:parent_manual_directory_id].present?
    @manual_directory = ManualDirectory.new
  end

  def edit
    @parent_manual_directory = @manual_directory.parent
    @parent_manual_directories = ManualDirectory.where(ancestry:nil)
  end

  def create
    if params[:manual_directory][:parent_manual_directory_id].present?
      @parent_manual_directory = ManualDirectory.find(params[:manual_directory][:parent_manual_directory_id])
      @manual_directory = @parent_manual_directory.children.create(manual_directory_params)
    else
      @manual_directory = ManualDirectory.create(manual_directory_params)
    end
    respond_to do |format|
      if @manual_directory
        format.html { redirect_to manual_directory_url(@manual_directory), notice: "Manual was successfully created." }
        format.json { render :show, status: :created, location: @manual_directory }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @manual_directory.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @manual_directory.update(manual_directory_params)
        format.html { redirect_to manual_directory_url(@manual_directory), notice: "Manual was successfully updated." }
        format.json { render :show, status: :ok, location: @manual_directory }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @manual_directory.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @manual_directory.destroy

    respond_to do |format|
      format.html { redirect_to manual_directories_url, notice: "Manual was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_manual_directory
      @manual_directory = ManualDirectory.find(params[:id])
    end

    def manual_directory_params
      params.require(:manual_directory).permit(:id,:title,manuals_attributes: [:id,:manual_directory_id,:picture,:content,:_destroy])
    end
end
