class DailyItemsController < ApplicationController
  before_action :set_daily_item, only: %i[ show edit update destroy ]

  def label
    store_id = params[:store_id]
    labels = []
    @date = params[:date]
    @daily_items = DailyItem.includes(:item).where(date:@date).order("id DESC")
    @daily_item_stores = DailyItemStore.where(daily_item_id:@daily_items.ids,store_id:store_id)
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "#{@date}_buppan_label_.csv", type: :csv
      end
    end
  end


  def calendar
    if params[:start_date]
      date = params[:start_date].to_date
    else
      date = @today
    end
    dates =(date.beginning_of_month..date.end_of_month).to_a
    @daily_items = DailyItem.where(date:dates,purpose:"物販")
    @category_sum = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @buppan_sum = {"estimated_sales_sum"=>0,"subtotal_price_sum"=>0,"arari_sum"=>0,"purchase_price_sum"=>0,"delivery_fee_sum"=>0}
    ["野菜","果物","物産","送料"].each do |category|
      daily_items = @daily_items.joins(:item).where(:items => {category:category})
      subtotal_price_sum = daily_items.sum(:subtotal_price)
      delivery_fee_sum = daily_items.sum(:delivery_fee)
      purchase_price_sum = daily_items.map{|di|di.purchase_price * di.delivery_amount}.sum
      estimated_sales = daily_items.sum(:estimated_sales)
      arari = estimated_sales - subtotal_price_sum
      @buppan_sum["estimated_sales_sum"] += estimated_sales
      @buppan_sum["subtotal_price_sum"] += subtotal_price_sum
      @buppan_sum["purchase_price_sum"] += purchase_price_sum
      @buppan_sum["delivery_fee_sum"] += delivery_fee_sum
      @buppan_sum["arari_sum"] += arari
      @category_sum[category]["estimated_sales_sum"] = estimated_sales
      @category_sum[category]["purchase_price_sum"] = purchase_price_sum
      @category_sum[category]["delivery_fee_sum"] = delivery_fee_sum
      @category_sum[category]["subtotal_price_sum"] = subtotal_price_sum
      @category_sum[category]["arari_sum"] = arari
      @category_sum[category]["arari_rate"] = (arari/estimated_sales.to_f*100).round(1) if estimated_sales > 0
    end
  end

  def index
    @stores = current_user.group.stores
    @item_vendors = ItemVendor.where(unused_flag:false)
    if params[:date].present?
      @date = params[:date].to_date
    else
      @date = @today 
    end
    @item = Item.new
    @daily_items = DailyItem.includes(daily_item_stores:[:store]).where(date:@date)
    @buppan_daily_items = DailyItem.where(date:@date,purpose:"物販").joins(:item).order('items.category').order("id DESC")
    @sozai_daily_items = DailyItem.where(date:@date,purpose:"惣菜").joins(:item).order('items.category').order("id DESC")
    @category_sum = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @buppan_sum = {"estimated_sales_sum"=>0,"subtotal_price_sum"=>0,"arari_sum"=>0,"purchase_price_sum"=>0,"delivery_fee_sum"=>0}
    ["野菜","果物","物産","送料"].each do |category|
      daily_items = DailyItem.joins(:item).where(:items => {category:category}).where(purpose:"物販",date:@date)
      subtotal_price_sum = daily_items.sum(:subtotal_price)
      delivery_fee_sum = daily_items.sum(:delivery_fee)
      purchase_price_sum = daily_items.map{|di|di.purchase_price * di.delivery_amount}.sum
      estimated_sales = daily_items.sum(:estimated_sales)
      arari = estimated_sales - subtotal_price_sum
      @buppan_sum["estimated_sales_sum"] += estimated_sales
      @buppan_sum["subtotal_price_sum"] += subtotal_price_sum
      @buppan_sum["purchase_price_sum"] += purchase_price_sum
      @buppan_sum["delivery_fee_sum"] += delivery_fee_sum
      @buppan_sum["arari_sum"] += arari
      @category_sum[category]["estimated_sales_sum"] = estimated_sales
      @category_sum[category]["purchase_price_sum"] = purchase_price_sum
      @category_sum[category]["delivery_fee_sum"] = delivery_fee_sum
      @category_sum[category]["subtotal_price_sum"] = subtotal_price_sum
      @category_sum[category]["arari_sum"] = arari
      @category_sum[category]["arari_rate"] = (arari/estimated_sales.to_f*100).round(1) if estimated_sales > 0
    end
    @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    DailyItemStore.includes(:daily_item).where(daily_item_id:@daily_items.ids).each do |dis|
      if dis.subordinate_amount > 0
        @hash[dis.daily_item_id][dis.store_id]["subordinate_amount"] = dis.subordinate_amount
        @hash[dis.daily_item_id][dis.store_id]["unit"] = dis.daily_item.unit
        @hash[dis.daily_item_id][dis.store_id]["sell_price"] = "#{dis.sell_price}円"
      else
        @hash[dis.daily_item_id][dis.store_id]["subordinate_amount"] = ''
        @hash[dis.daily_item_id][dis.store_id]["unit"] = ''
        @hash[dis.daily_item_id][dis.store_id]["sell_price"] = ''
      end
    end
    @items = Item.includes([:item_vendor]).all
    @daily_item = DailyItem.new(date:@date)
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
    @stores = current_user.group.stores
    @daily_item = DailyItem.new(daily_item_params)
    respond_to do |format|
      if @daily_item.save
        @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
        @daily_item.daily_item_stores.each do |dis|
          if dis.subordinate_amount > 0
            @hash[dis.daily_item_id][dis.store_id]["subordinate_amount"] = dis.subordinate_amount
            @hash[dis.daily_item_id][dis.store_id]["unit"] = dis.daily_item.unit
            @hash[dis.daily_item_id][dis.store_id]["sell_price"] = "#{dis.sell_price}円"
          else
            @hash[dis.daily_item_id][dis.store_id]["subordinate_amount"] = ''
            @hash[dis.daily_item_id][dis.store_id]["unit"] = ''
            @hash[dis.daily_item_id][dis.store_id]["sell_price"] = ''
          end
        end
        @new_daily_item = DailyItem.new(date:@daily_item.date)
        @items = Item.all
        @item_vendors = ItemVendor.all
        @stores.each do |store|
          @new_daily_item.daily_item_stores.build(store_id:store.id,subordinate_amount:0)
        end
        format.html { redirect_to daily_item_url(@daily_item), info: "作成しました。" }
        format.js
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @daily_item.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @stores = current_user.group.stores
    respond_to do |format|
      if @daily_item.update(daily_item_params)
        @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
        @daily_item.daily_item_stores.each do |dis|
          if dis.subordinate_amount > 0
            @hash[dis.daily_item_id][dis.store_id]["subordinate_amount"] = dis.subordinate_amount
            @hash[dis.daily_item_id][dis.store_id]["unit"] = dis.daily_item.unit
            @hash[dis.daily_item_id][dis.store_id]["sell_price"] = "#{dis.sell_price}円"
          else
            @hash[dis.daily_item_id][dis.store_id]["subordinate_amount"] = ''
            @hash[dis.daily_item_id][dis.store_id]["unit"] = ''
            @hash[dis.daily_item_id][dis.store_id]["sell_price"] = ''
          end
        end
        format.html { redirect_to daily_items_path(date:@daily_item.date), info: "#{@daily_item.item.item_vendor.store_name} の #{@daily_item.item.name}/#{@daily_item.item.variety} を更新しました。" }
        format.js
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @daily_item.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @daily_item.destroy
    respond_to do |format|
      format.html { redirect_to daily_items_path(date:@daily_item.date), info: "削除しました。" }
      format.json { head :no_content }
    end
  end

  private
    def set_daily_item
      @daily_item = DailyItem.find(params[:id])
    end

    def daily_item_params
      params.require(:daily_item).permit(:date,:purpose,:item_id,:memo,:estimated_sales,:tax_including_estimated_sales,:purchase_price,
        :tax_including_purchase_price,:delivery_fee,:tax_including_delivery_fee,:subtotal_price,:tax_including_subtotal_price,:unit,:delivery_amount,
        daily_item_stores_attributes:[:id,:daily_item_id,:store_id,:subordinate_amount,:sell_price,:tax_including_sell_price,:_destroy]
        )
    end
end
