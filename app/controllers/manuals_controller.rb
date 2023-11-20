class ManualsController < ApplicationController
  before_action :set_manual, only: %i[ show edit update destroy ]

  def index
    @manuals = Manual.all
  end

  def show
  end

  def new
    @parent_manual = Manual.find(params[:parent_manual_id]) if params[:parent_manual_id].present?
    @manual = Manual.new
  end

  def edit
  end

  def create
    if params[:manual][:parent_manual_id].present?
      @parent_manual = Manual.find(params[:manual][:parent_manual_id])
      @manual = @parent_manual.children.new(manual_params)
    else
      @manual = Manual.new(manual_params)
    end

    respond_to do |format|
      if @manual.save
        format.html { redirect_to manual_url(@manual), notice: "Manual was successfully created." }
        format.json { render :show, status: :created, location: @manual }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @manual.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @manual.update(manual_params)
        format.html { redirect_to manual_url(@manual), notice: "Manual was successfully updated." }
        format.json { render :show, status: :ok, location: @manual }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @manual.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @manual.destroy

    respond_to do |format|
      format.html { redirect_to manuals_url, notice: "Manual was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_manual
      @manual = Manual.find(params[:id])
    end

    def manual_params
      params.require(:manual).permit(:id,:title,:video,:date,:parent_manual_id)
    end
end
