class CommonProductPartsController < ApplicationController
  before_action :set_common_product_part, only: %i[ show edit update destroy ]

  def get_common_product_part
    if params[:common_product_part_id].present?
      @common_product_part = CommonProductPart.find(params[:common_product_part_id])
    else
      @common_product_part = nil
    end
    @index = params[:index]
    respond_to do |format|
      format.html
      format.json { render json: { common_product_part:@common_product_part,index:@index} }
    end    
  end
  def index
    @common_product_parts = CommonProductPart.all
  end

  def show
  end

  def new
    @common_product_part = CommonProductPart.new
  end

  def edit
  end

  def create
    @common_product_part = CommonProductPart.new(common_product_part_params)

    respond_to do |format|
      if @common_product_part.save
        format.html { redirect_to common_product_parts_path, info: "保存！" }
        format.json { render :show, status: :created, location: @common_product_part }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @common_product_part.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @common_product_part.update(common_product_part_params)
        format.html { redirect_to common_product_parts_path, info: "保存！" }
        format.json { render :show, status: :ok, location: @common_product_part }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @common_product_part.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @common_product_part.destroy

    respond_to do |format|
      format.html { redirect_to common_product_parts_url, notice: "Common product part was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_common_product_part
      @common_product_part = CommonProductPart.find(params[:id])
    end

    def common_product_part_params
      params.require(:common_product_part).permit(:name,:unit,:memo,:container,:loading_position,:loading_container,:product_name)
    end
end
