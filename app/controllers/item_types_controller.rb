class ItemTypesController < ApplicationController
  before_action :set_item_type, only: %i[ show edit update destroy ]

  def index
    @item_types = ItemType.all
  end

  def show
  end

  def new
    @item_type = ItemType.new
  end

  def edit
  end

  def create
    @item_type = ItemType.new(item_type_params)

    respond_to do |format|
      if @item_type.save
        format.html { redirect_to item_type_url(@item_type), notice: "Item type was successfully created." }
        format.json { render :show, status: :created, location: @item_type }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @item_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @item_type.update(item_type_params)
        format.html { redirect_to item_type_url(@item_type), notice: "Item type was successfully updated." }
        format.json { render :show, status: :ok, location: @item_type }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @item_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @item_type.destroy

    respond_to do |format|
      format.html { redirect_to item_types_url, notice: "Item type was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_item_type
      @item_type = ItemType.find(params[:id])
    end

    def item_type_params
      params.require(:item_type).permit(:name,:category,:storage,:display,:feature,:cooking,:choice)
    end
end
