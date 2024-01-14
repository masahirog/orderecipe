class ItemsController < ApplicationController
  before_action :set_item, only: %i[ show edit update destroy ]

  def get_item
    id = params[:id]
    @item = Item.find(id)
  end

  def get_vendor_items
    item_vendor_id = params[:item_vendor_id]
    @items = Item.where(item_vendor_id:item_vendor_id).order(:name)
  end
  def index
    @search = Item.includes([:item_vendor]).search(params).page(params[:page]).per(50)
  end

  def show
  end

  def new
    @item = Item.new
  end

  def edit
  end

  def create
    @item = Item.new(item_params)
    respond_to do |format|
      if @item.save
        @new_item = Item.new
        format.html { redirect_to item_url(@item), notice: "Item was successfully created." }
        format.js
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @item.update(item_params)
        format.html { redirect_to item_url(@item), notice: "Item was successfully updated." }
        format.json { render :show, status: :ok, location: @item }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @item.destroy

    respond_to do |format|
      format.html { redirect_to items_url, notice: "Item was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_item
      @item = Item.find(params[:id])
    end

    def item_params
      params.require(:item).permit(:name,:variety,:category,:memo,:reduced_tax_flag,:sell_price,:tax_including_sell_price,
        :purchase_price,:tax_including_purchase_price,:unit,:item_vendor_id,:smaregi_code,:sales_life)
    end
end
