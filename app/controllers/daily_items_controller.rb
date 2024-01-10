class DailyItemsController < ApplicationController
  before_action :set_daily_item, only: %i[ show edit update destroy ]
  def calendar
    @daily_items = DailyItem.includes(:item).order("id DESC")
  end
  def index
    @item_vendors = ItemVendor.all
    if params[:date].present?
      @date = params[:date].to_date
    else
      @date = @today 
    end
    @item = Item.new
    @daily_items = DailyItem.includes(:item).where(date:@date).order("id DESC")
    @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    DailyItemStore.where(daily_item_id:@daily_items.ids).each do |dis|
      if dis.subordinate_amount > 0
        @hash[dis.daily_item_id][dis.store_id] = dis.subordinate_amount
      else
        @hash[dis.daily_item_id][dis.store_id] = ''
      end
    end
    @items = Item.includes([:item_vendor]).all
    @daily_item = DailyItem.new(date:@date)
    @stores = current_user.group.stores
    @stores.each do |store|
      @daily_item.daily_item_stores.build(store_id:store.id,subordinate_amount:0)
    end

  end

  def show
  end

  def new
    @items = Item.all
    @daily_item = DailyItem.new
    @stores.each do |store|
      @daily_item.daily_item_stores.build(store_id:store.id,subordinate_amount:0)
    end
  end

  def edit
  end

  def create
    @daily_item = DailyItem.new(daily_item_params)
    respond_to do |format|
      if @daily_item.save
        @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
        @daily_item.daily_item_stores.each do |dis|
          if dis.subordinate_amount > 0
            @hash[dis.daily_item_id][dis.store_id] = dis.subordinate_amount
          else
            @hash[dis.daily_item_id][dis.store_id] = ''
          end
        end
        @new_daily_item = DailyItem.new(date:@daily_item.date)
        @items = Item.all
        @item_vendors = ItemVendor.all
        @stores.each do |store|
          @new_daily_item.daily_item_stores.build(store_id:store.id,subordinate_amount:0)
        end
        format.html { redirect_to daily_item_url(@daily_item), notice: "Daily item was successfully created." }
        format.js
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @daily_item.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @daily_item.update(daily_item_params)
        format.html { redirect_to daily_item_url(@daily_item), notice: "Daily item was successfully updated." }
        format.json { render :show, status: :ok, location: @daily_item }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @daily_item.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @daily_item.destroy

    respond_to do |format|
      format.html { redirect_to daily_items_url, notice: "Daily item was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_daily_item
      @daily_item = DailyItem.find(params[:id])
    end

    def daily_item_params
      params.require(:daily_item).permit(:date,:purpose,:item_id,:memo,:sell_price,:tax_including_sell_price,:purchase_price,
        :tax_including_purchase_price,:delivery_fee,:tax_including_delivery_fee,:subtotal_price,:tax_including_subtotal_price,:unit,:delivery_amount,
        daily_item_stores_attributes:[:id,:daily_item_id,:store_id,:subordinate_amount,:_destroy]
        )
    end
end
