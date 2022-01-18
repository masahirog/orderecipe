class KaizenListsController < ApplicationController
  before_action :set_kaizen_list, only: %i[ show edit update destroy ]

  def index
    @kaizen_lists = KaizenList.includes([:product]).all.order('priority desc')
  end

  def show
  end

  def new
    @kaizen_list = KaizenList.new
  end

  def edit
  end

  def create
    @kaizen_list = KaizenList.new(kaizen_list_params)

    respond_to do |format|
      if @kaizen_list.save
        format.html { redirect_to kaizen_lists_path, notice: "Kaizen list was successfully created." }
        format.json { render :show, status: :created, location: @kaizen_list }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @kaizen_list.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @kaizen_list.update(kaizen_list_params)
        format.html { redirect_to kaizen_lists_path, notice: "Kaizen list was successfully updated." }
        format.json { render :show, status: :ok, location: @kaizen_list }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @kaizen_list.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @kaizen_list.destroy
    respond_to do |format|
      format.html { redirect_to kaizen_lists_url, notice: "Kaizen list was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_kaizen_list
      @kaizen_list = KaizenList.find(params[:id])
    end

    def kaizen_list_params
      params.require(:kaizen_list).permit(:id,:product_id,:author,:kaizen_staff,:kaizen_point,:priority,:status,:kaizen_result,:or_change_flag,:share_flag,:after_image,:before_image,
      :before_image_cache,:remove_before_image,:after_image_cache,:remove_after_image)
    end
end
