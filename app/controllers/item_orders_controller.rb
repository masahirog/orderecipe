class ItemOrdersController < ApplicationController
  before_action :set_item_order, only: %i[ show edit update destroy ]

  def index
    @item_orders = ItemOrder.where(store_id:params[:store_id])
    @store = Store.find(params[:store_id])
  end

  def show
  end

  def new
    @store = Store.find(params[:store_id])
    @item_order = ItemOrder.new(store_id:@store.id,delivery_date:@today+1)

    item_types = ItemType.where(category:"物産品")
    @items = Item.where(stock_store_id:39).order(:item_vendor_id)
    @items.each do |item|
      @item_order.item_order_items.build(item_id:item.id)
    end
  end

  def edit
    @store = Store.find(@item_order.store_id)
    item_types = ItemType.where(category:"物産品")
    kizon_item_ids = @item_order.item_order_items.map{|ioi|ioi.item_id}
    @items = Item.where(stock_store_id:39).where.not(id:kizon_item_ids).order(:item_vendor_id)
    @items.each do |item|
      @item_order.item_order_items.build(item_id:item.id)
    end
  end

  def create
    @item_order = ItemOrder.new(item_order_params)

    respond_to do |format|
      if @item_order.save
        format.html { redirect_to item_order_url(@item_order), info: "保存しました。" }
        format.json { render :show, status: :created, location: @item_order }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @item_order.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @item_order.update(item_order_params)
        format.html { redirect_to item_order_url(@item_order), info: "保存しました。" }
        format.json { render :show, status: :ok, location: @item_order }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @item_order.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @item_order.destroy

    respond_to do |format|
      format.html { redirect_to item_orders_url, notice: "Item order was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_item_order
      @item_order = ItemOrder.find(params[:id])
    end

    def item_order_params
      params.require(:item_order).permit(:store_id,:delivery_date,:memo,:fixed_flag,:staff_name,
        item_order_items_attributes:[:id,:item_order_id,:item_id,:order_quantity,:memo,:un_order_flag,:_destroy])

    end
end

