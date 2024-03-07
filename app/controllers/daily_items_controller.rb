class DailyItemsController < ApplicationController
  before_action :set_daily_item, only: %i[ show edit update destroy ]

  def monthly
    if params[:month].present?
      date = "#{params[:month]}-01".to_date
      @month = params[:month]
    else
      date = params[:date].to_date
      @month = "#{date.year}-#{sprintf("%02d",date.month)}"
    end

    if params[:item_vendor_id].present?
      item_vendors = ItemVendor.where(id:params[:item_vendor_id])
    else
      item_vendors = ItemVendor.all
    end
    item_vendors = item_vendors.where(payment:params[:payment]) if params[:payment].present?

    @dates =(date.beginning_of_month..date.end_of_month).to_a
    @daily_items = DailyItem.includes(item:[:item_vendor,item_variety:[:item_type]]).joins(:item).where(:items => {item_vendor_id:item_vendors.ids},date:@dates).order(:date)
    @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @daily_items.each do |di|
      @hash[di.item.item_vendor_id][:daily_items][di.id] = di
      if @hash[di.item.item_vendor_id][:reduced_tax_subject].present?
        if di.item.reduced_tax_flag == true
          @hash[di.item.item_vendor_id][:reduced_tax_subject] += (di.tax_including_purchase_price * di.delivery_amount)
          @hash[di.item.item_vendor_id][:normal_tax_subject] += di.tax_including_delivery_fee
        else
          @hash[di.item.item_vendor_id][:normal_tax_subject] += di.tax_including_subtotal_price
        end
      else
        if di.item.reduced_tax_flag == true
          @hash[di.item.item_vendor_id][:reduced_tax_subject] = (di.tax_including_purchase_price * di.delivery_amount)
          @hash[di.item.item_vendor_id][:normal_tax_subject] = di.tax_including_delivery_fee
        else
          @hash[di.item.item_vendor_id][:reduced_tax_subject] = 0
          @hash[di.item.item_vendor_id][:normal_tax_subject] = di.tax_including_subtotal_price
        end
      end
    end
    @item_vendors = ItemVendor.where(id:@hash.keys)
    respond_to do |format|
      format.html
      format.pdf do
        pdf = DailyItemInvoice.new(date,@item_vendors,@hash)
        send_data pdf.render,
        filename:    "#{@date}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
      format.csv do
        send_data render_to_string, filename: "daily_items.csv", type: :csv
      end
    end
  end

  def vendor
    @date = params[:date].to_date
    @dates =(@date.beginning_of_month..@date.end_of_month).to_a
    @monthly_datas = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }    
    DailyItem.where(date:@dates).each do |di|
      if @monthly_datas[di.item.item_vendor_id].present?
        @monthly_datas[di.item.item_vendor_id][:purchase_price_sum] += di.purchase_price
        @monthly_datas[di.item.item_vendor_id][:tax_including_purchase_price_sum] += di.tax_including_purchase_price
      else
        @monthly_datas[di.item.item_vendor_id][:store_name] = di.item.item_vendor.store_name
        @monthly_datas[di.item.item_vendor_id][:purchase_price_sum] = di.purchase_price
        @monthly_datas[di.item.item_vendor_id][:tax_including_purchase_price_sum] = di.tax_including_purchase_price
      end
    end
    
  end

  def loading_sheet
    @date = params[:date]
    @buppan_schedule = BuppanSchedule.find_by(date:@date)
    if params[:sorting_base_id].present?
      @sorting_base = ItemVendor.sorting_base_ids.invert[params[:sorting_base_id].to_i]
      @daily_items = DailyItem.includes(:daily_item_stores,item:[:item_vendor]).joins(:item => :item_vendor).where(:item => {:item_vendors => {sorting_base_id:params[:sorting_base_id]}}).where(date:@date)
    else
      @sorting_base = "全て"
      @daily_items = DailyItem.includes(:daily_item_stores,item:[:item_vendor]).where(date:@date)
    end
    @stores = current_user.group.stores.where.not(store_type:'head_office')
    respond_to do |format|
      format.html
      format.pdf do
        pdf = DailyItemLoadingSheet.new(@date,@daily_items,@stores,@buppan_schedule,@sorting_base)
        send_data pdf.render,
        filename:    "#{@date}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end

    end
  end

  def label
    @store = Store.find(params[:store_id])
    @date = params[:date]
    @daily_items = DailyItem.where(date:@date)
    @daily_item_stores = DailyItemStore.where(daily_item_id:@daily_items.ids,store_id:@store.id).where('subordinate_amount > ?',0)
  end

  def barcode_csv
    store_id = params[:store_id]
    labels = []
    @date = params[:date]
    if store_id.present?
      @daily_items = DailyItem.includes(:daily_item_stores,item:[:item_vendor]).where(date:@date).order("id DESC")
      @daily_item_stores = DailyItemStore.where(daily_item_id:@daily_items.ids,store_id:store_id)
    else
      @daily_items = DailyItem.includes(:daily_item_stores,item:[:item_vendor]).joins(:item => :item_vendor).where(:item => {:item_vendors => {sorting_base_id:"SKL練馬"}}).where(date:@date)
      @daily_item_stores = DailyItemStore.where(daily_item_id:@daily_items.ids)
    end
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "#{@date}_buppan_label_.csv", type: :csv
      end
    end
  end

  def store_barcode_csv
    store_id = params[:store_id]
    @date = params[:date]
    @hash = params["daily_item_store"]
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "#{@date}_buppan_label_.csv", type: :csv
      end
    end
  end


  def calendar
    if params[:start_date]
      @date = params[:start_date].to_date
    else
      @date = @today
    end
    dates =(@date.beginning_of_month..@date.end_of_month).to_a
    @daily_items = DailyItem.where(date:dates,purpose:"物販")
    @category_sum = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @buppan_sum = {"estimated_sales_sum"=>0,"subtotal_price_sum"=>0,"arari_sum"=>0,"purchase_price_sum"=>0,"delivery_fee_sum"=>0}
    ["野菜","果実","物産品","送料"].each do |category|
      item_varieties = ItemVariety.joins(:item_type).where(:item_types => {category:category})
      items = Item.where(item_variety_id:item_varieties.ids)
      daily_items = @daily_items.where(item_id:items.ids)
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
    @item_varieties = ItemVariety.includes(:item_type).all
    @stores = current_user.group.stores.where.not(store_type:'head_office')
    @item_vendors = ItemVendor.where(unused_flag:false)
    if params[:date].present?
      @date = params[:date].to_date
    else
      @date = @today 
    end
    @buppan_schedule = BuppanSchedule.find_by(date:@date)
    if @buppan_schedule.present?
    else
      @buppan_schedule = BuppanSchedule.new(date:@date)
    end
    @item = Item.new
    @daily_items = DailyItem.includes(item:[:item_variety],daily_item_stores:[:store]).where(date:@date)
    @buppan_daily_items = @daily_items.where(purpose:"物販").order("id DESC")
    @sozai_daily_items = @daily_items.where(purpose:"惣菜").order("id DESC")
    @category_sum = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @buppan_sum = {"estimated_sales_sum"=>0,"subtotal_price_sum"=>0,"arari_sum"=>0,"purchase_price_sum"=>0,"delivery_fee_sum"=>0}
    ["野菜","果実","物産品","送料"].each do |category|
      item_varieties = ItemVariety.includes(:item_type).where(:item_types => {category:category})
      items = Item.where(item_variety_id:item_varieties.ids)
      daily_items = @daily_items.where(item_id:items.ids,purpose:"物販")
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
    DailyItemStore.where(daily_item_id:@daily_items.ids).each do |dis|
      if dis.subordinate_amount > 0
        @hash[dis.daily_item_id][dis.store_id]["subordinate_amount"] = dis.subordinate_amount
        @hash[dis.daily_item_id][dis.store_id]["unit"] = dis.daily_item.item.unit
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
    @stores = current_user.group.stores.where.not(store_type:'head_office')
    @daily_item = DailyItem.new(daily_item_params)
    respond_to do |format|
      if @daily_item.save
        @item_varieties = ItemVariety.includes(:item_type).all
        @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
        @daily_item.daily_item_stores.each do |dis|
          if dis.subordinate_amount > 0
            @hash[dis.daily_item_id][dis.store_id]["subordinate_amount"] = dis.subordinate_amount
            @hash[dis.daily_item_id][dis.store_id]["unit"] = dis.daily_item.item.unit
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
    @stores = current_user.group.stores.where.not(store_type:'head_office')
    respond_to do |format|
      if @daily_item.update(daily_item_params)
        @item_varieties = ItemVariety.includes(:item_type).all
        @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
        @daily_item.daily_item_stores.each do |dis|
          if dis.subordinate_amount > 0
            @hash[dis.daily_item_id][dis.store_id]["subordinate_amount"] = dis.subordinate_amount
            @hash[dis.daily_item_id][dis.store_id]["order_unit"] = dis.daily_item.order_unit
            @hash[dis.daily_item_id][dis.store_id]["sell_price"] = "#{dis.sell_price}円"
          else
            @hash[dis.daily_item_id][dis.store_id]["subordinate_amount"] = ''
            @hash[dis.daily_item_id][dis.store_id]["order_unit"] = ''
            @hash[dis.daily_item_id][dis.store_id]["sell_price"] = ''
          end
        end
        format.html { redirect_to daily_items_path(date:@daily_item.date), info: "#{@daily_item.item.item_vendor.store_name} の #{@daily_item.item.name}を更新しました。" }
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
      params.require(:daily_item).permit(:date,:purpose,:item_id,:memo,:estimated_sales,:tax_including_estimated_sales,:purchase_price,:sorting_memo,:adjustment_subtotal,
        :tax_including_purchase_price,:delivery_fee,:tax_including_delivery_fee,:subtotal_price,:tax_including_subtotal_price,:order_unit,:delivery_amount,:order_unit_amount,
        daily_item_stores_attributes:[:id,:daily_item_id,:store_id,:subordinate_amount,:sell_price,:tax_including_sell_price,:_destroy]
        )
    end
end
