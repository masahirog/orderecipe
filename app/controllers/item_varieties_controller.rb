class ItemVarietiesController < ApplicationController
  before_action :set_item_variety, only: %i[ show edit update destroy ]

  def index
    @item_varieties = ItemVariety.all
  end

  def show
  end

  def new
    @item_variety = ItemVariety.new(item_type_id:params[:item_type_id])
    @item_types = ItemType.all
  end

  def edit
    @item_types = ItemType.all
  end

  def create
    @item_variety = ItemVariety.new(item_variety_params)
    respond_to do |format|
      if @item_variety.save
        format.html { redirect_to item_type_path(@item_variety.item_type), success: "作成完了" }
        format.json { render :show, status: :created, location: @item_variety }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @item_variety.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @item_variety.update(item_variety_params)
        format.html { redirect_to item_type_path(@item_variety.item_type), notice: "更新完了" }
        format.json { render :show, status: :ok, location: @item_variety }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @item_variety.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @item_variety.destroy

    respond_to do |format|
      format.html { redirect_to item_varieties_url, notice: "Item variety was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_item_variety
      @item_variety = ItemVariety.find(params[:id])
    end

    def item_variety_params
      params.require(:item_variety).permit(:item_type_id,:name,:image,:storage,:display,:feature,:cooking,:choice)
    end
end