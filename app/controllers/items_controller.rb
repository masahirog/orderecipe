class ItemsController < ApplicationController
  before_action :set_item, only: %i[ show edit update destroy ]
  def store
    @store = Store.find(params[:store_id])
    @search = Item.includes(:item_vendor,:daily_items).search(params).page(params[:page]).per(50)
    @hash = {}
    @search.each do |item|
      if item.daily_items.present?
        @hash[item.id] = true
      else
        @hash[item.id] = false
      end
    end
  end


  def get_item
    id = params[:id]
    @item = Item.find(id)
    @target_id = params[:target_id]
  end

  def get_vendor_items
    item_vendor_id = params[:item_vendor_id]
    if item_vendor_id.present?
      @items = Item.where(item_vendor_id:item_vendor_id).order(:name)
    else
      @items = Item.all.order(:name)
    end
  end

  def index
    @search = Item.includes(:item_vendor,:daily_items,item_variety:[:item_type]).search(params).page(params[:page]).per(50)
    @hash = {}
    @search.each do |item|
      if item.daily_items.present?
        @hash[item.id] = true
      else
        @hash[item.id] = false
      end
    end
  end

  def show
  end

  def new
    @item = Item.new
    @item_varieties = ItemVariety.all
  end

  def edit
    @item_varieties = ItemVariety.all
  end

  def create
    @item = Item.new(item_params)
    respond_to do |format|
      if @item.save
        @item_varieties = ItemVariety.includes(:item_type).all
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
        @item_varieties = ItemVariety.includes(:item_type).all
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
      params.require(:item).permit(:name,:item_variety_id,:memo,:reduced_tax_flag,:sell_price,:tax_including_sell_price,
        :purchase_price,:tax_including_purchase_price,:unit,:item_vendor_id,:smaregi_code,:sales_life)
    end
end
