class AnalysesController < ApplicationController
  before_action :set_analysis, only: %i[ show edit update destroy ]
  def bulk_delete_analysis_products
    # データ検証の商品情報を一括削除
    analysis_id = params[:analysis_id]
    analysis = Analysis.find(analysis_id)
    analysis_products = analysis.analysis_products
    count = analysis_products.count
    analysis_products.destroy_all
    redirect_to analysis, :alert => "#{count}件を削除しました。"

  end
  def smaregi_trading_history_totalling
    #アップロード済みのスマレジの販売履歴を計算する
    analysis_id = params[:analysis]["analysis_id"]
    @analysis = Analysis.find(analysis_id)
    smaregi_shohin_ids = @analysis.analysis_products.map{|ap|ap.smaregi_shohin_id}
    smaregi_trading_histories = SmaregiTradingHistory.where(analysis_id:analysis_id)
    analysis_products_arr = []
    @product_sales_number = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }

    smaregi_trading_histories.each do |sth|
      if sth.torihiki_meisaikubun == 1
        suryo = sth.suryo
        nebikigokei = sth.nebikigokei
      else
        suryo = -1 * sth.suryo
        nebikigokei = -1 * sth.nebikigokei
      end
      if @product_sales_number[sth.shohin_id].present?
        @product_sales_number[sth.shohin_id][:suryo] += suryo
        @product_sales_number[sth.shohin_id][:nebikigokei] += nebikigokei
      else
        @product_sales_number[sth.shohin_id][:suryo] = suryo
        @product_sales_number[sth.shohin_id][:nebikigokei] = nebikigokei
      end
      if smaregi_shohin_ids.include?(sth.shohin_id)
      else
        new_analysis_product = AnalysisProduct.new(analysis_id:sth.analysis_id,smaregi_shohin_id:sth.shohin_id,smaregi_shohin_name:sth.shohinmei,smaregi_shohintanka:sth.shohintanka,
        product_id:sth.hinban,total_sales_amount:0,sales_number:0,loss_amount:0)
        analysis_products_arr << new_analysis_product
        smaregi_shohin_ids << sth.shohin_id
      end
    end
    AnalysisProduct.import analysis_products_arr
    update_analysis_products_arr = []
    @analysis.analysis_products.each do |ap|
      ap.sales_number = @product_sales_number[ap.smaregi_shohin_id][:suryo]
      ap.total_sales_amount = @product_sales_number[ap.smaregi_shohin_id][:nebikigokei]
      update_analysis_products_arr << ap
    end
    AnalysisProduct.import update_analysis_products_arr, on_duplicate_key_update:[:sales_number,:total_sales_amount]
    redirect_to @analysis
  end
  def products
    #データ検証の商品情報を更新する
    total_loass_amount = 0
    analysis_id = params[:analysis]["analysis_id"]
    @analysis = Analysis.find(analysis_id)
    # smaregi_trading_histories = SmaregiTradingHistory.where(analysis_id:analysis_id)
    @store_daily_menu = StoreDailyMenu.find_by(start_time:@analysis.date,store_id:@analysis.store_id)
    analysis_product_shohin_ids = []
    update_analysis_products_arr = []
    new_analysis_products_arr = []
    @store_daily_menu.store_daily_menu_details.each do |sdmd|
      analysis_products = @analysis.analysis_products.where(product_id:sdmd.product_id)
      if analysis_products.length > 1
        analysis_products.each do |analysis_product|
          analysis_product.list_price = 0
          analysis_product.manufacturing_number = 0
          analysis_product.carry_over = 0
          analysis_product.actual_inventory = 0
          update_analysis_products_arr << analysis_product
          analysis_product_shohin_ids << analysis_product.shohin_id
        end
      elsif analysis_products.length == 1
        analysis_product = analysis_products[0]
        analysis_product.list_price = sdmd.product.sell_price
        analysis_product.manufacturing_number = sdmd.number
        analysis_product.carry_over = sdmd.carry_over
        analysis_product.actual_inventory = sdmd.actual_inventory

        if analysis_product.sales_number.present?
          analysis_product.loss_number = analysis_product.actual_inventory - analysis_product.sales_number
          loss_amount = analysis_product.list_price * analysis_product.loss_number
          if loss_amount < 0 || analysis_product.product_id == 10459
            analysis_product.loss_amount = 0
          else
            analysis_product.loss_amount = loss_amount
            total_loass_amount += loss_amount
          end
        else
          analysis_product.loss_number = 0
          analysis_product.loss_amount = 0
          total_loass_amount += 0
        end

        update_analysis_products_arr << analysis_product
        analysis_product_shohin_ids << analysis_product.smaregi_shohin_id
      else
        new_analysis_product = AnalysisProduct.new(analysis_id:analysis_id,product_id:sdmd.product_id,list_price:sdmd.product.sell_price,
          manufacturing_number:sdmd.number, carry_over:sdmd.carry_over,actual_inventory:sdmd.actual_inventory,loss_amount:0,loss_number:0)
        new_analysis_products_arr << new_analysis_product
      end
    end

    AnalysisProduct.import new_analysis_products_arr
    AnalysisProduct.import update_analysis_products_arr, on_duplicate_key_update:[:list_price,:manufacturing_number,:carry_over,:actual_inventory,
      :sales_number,:loss_number,:total_sales_amount,:loss_amount] if update_analysis_products_arr.present?
    @analysis.update(loss_amount:total_loass_amount)
    redirect_to @analysis
  end
  def date
    @date = params[:date]
    @stores = Store.all
    @analyses_hash = {}
    Analysis.where(date:@date).each do |analysis|
      @analyses_hash[analysis.store_id] = analysis
    end

  end
  def summary
    @stores = Store.all
    if params[:stores]
      checked_store_ids = params['stores'].keys
    else
      checked_store_ids = @stores.ids
      params[:stores] = {}
      @stores.each do |store|
        params[:stores][store.id.to_s] = true
      end
    end
    if params[:to]
      @to = params[:to].to_date
    else
      @to = Date.today
      params[:to] = @to
    end
    if params[:from]
      @from = params[:from].to_date
    else
      @from = @to - 30
      params[:from] = @from
    end
    gon.dates = (@from..@to).map{|date|date}
    @date_analyses = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    analyses = Analysis.where(date:@from..@to).where(store_id:checked_store_ids)
    analyses.each do |analysis|
      @date_analyses[analysis.date][analysis.store_id] = analysis
    end
    @date_transaction_count = analyses.group(:date).sum(:transaction_count)
    @date_sales_amount = analyses.group(:date).sum(:sales_amount)
    @date_loss_amount = analyses.group(:date).sum(:loss_amount)
    date_arr = []
    data_arr = []
    data_loss_arr = []
    date_transaction_count_arr = []
    haiki_mokuhyo_arr = []
    data_lossamount_arr = []
    @date_sales_amount.sort.each do |date_sales|
      date_arr << date_sales[0].strftime("%-m/%-d (#{%w(日 月 火 水 木 金 土)[date_sales[0].wday]})")
      data_arr << date_sales[1]
      data_lossamount_arr << @date_loss_amount[date_sales[0]]
      data_loss_arr << ((@date_loss_amount[date_sales[0]].to_f/date_sales[1])*100).round(1)
      date_transaction_count_arr << @date_transaction_count[date_sales[0]]
      haiki_mokuhyo_arr << 6
    end
    gon.sales_dates = date_arr
    gon.sales_data = data_arr
    gon.loss_data = data_loss_arr
    gon.loss_mokuhyo_data = haiki_mokuhyo_arr
    gon.transaction_count_date = date_transaction_count_arr
    gon.lossamount_data = data_lossamount_arr
  end
  def index
    @stores = Store.all
    if params[:stores]
      checked_store_ids = params['stores'].keys
    else
      checked_store_ids = @stores.ids
      params[:stores] = {}
      @stores.each do |store|
        params[:stores][store.id.to_s] = true
      end
    end
    if params[:to]
      @to = params[:to].to_date
    else
      @to = Date.today
      params[:to] = @to
    end
    if params[:from]
      @from = params[:from].to_date
    else
      @from = @to - 30
      params[:from] = @from
    end
    @date_analyses = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    analyses = Analysis.where(date:@from..@to).where(store_id:checked_store_ids)
    analyses.each do |analysis|
      @date_analyses[analysis.date][analysis.store_id] = analysis
    end
    @date_sales_amount = analyses.group(:date).sum(:sales_amount)
    @date_loss_amount = analyses.group(:date).sum(:loss_amount)
    @date_transaction_count = analyses.group(:date).sum(:transaction_count)
  end

  def show
    @or_ari_analysis_products = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @or_nashi_analysis_products = []


    @shohin_id = params[:shohin_id]
    @hinban = params[:hinban]
    @shohinmei = params[:shohinmei]
    @smaregi_trading_histories = SmaregiTradingHistory.all
    @smaregi_trading_histories = @smaregi_trading_histories.where(analysis_id:@analysis.id)
    @shohin_ids = @smaregi_trading_histories.map{|sth|sth.shohin_id}.uniq
    @product_ids = @smaregi_trading_histories.map{|sth|sth.hinban}.uniq
    @shohinmeis = @smaregi_trading_histories.map{|sth|sth.shohinmei}.uniq
    @smaregi_trading_histories = @smaregi_trading_histories.where(shohin_id:@shohin_id) if @shohin_id.present?
    @smaregi_trading_histories = @smaregi_trading_histories.where(hinban:@hinban) if @hinban.present?
    @smaregi_trading_histories = @smaregi_trading_histories.where(shohinmei:@shohinmei) if @shohinmei.present?
    # @date_counts = @smaregi_trading_histories.group(:date).count()

    @smaregi_trading_histories = @smaregi_trading_histories.page(params[:page]).per(50)

    date = @analysis.date
    store_id = @analysis.store_id
    @store_daily_menu = StoreDailyMenu.find_by(start_time:date,store_id:store_id)
    @store_daily_menu_details = @store_daily_menu.store_daily_menu_details.includes([:product]).order(:row_order)
    sdmd_arr = @store_daily_menu_details.map{|sdmd|sdmd.product_id}
    @analysis.analysis_products.each do |ap|
      if sdmd_arr.include?(ap.product_id)
        if @or_ari_analysis_products[ap.product_id].present?
          @or_nashi_analysis_products << ap
        else
          @or_ari_analysis_products[ap.product_id] = ap
        end
      else
        @or_nashi_analysis_products << ap
      end
    end
  end

  def new
    @analysis = Analysis.new(store_id:params[:store_id],date:params[:date])
  end

  def edit
  end

  def create
    @analysis = Analysis.new(analysis_params)
    respond_to do |format|
      if @analysis.save
        format.html { redirect_to @analysis, notice: "Analysis was successfully created." }
        format.json { render :show, status: :created, location: @analysis }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @analysis.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @analysis.update(analysis_params)
        format.html { redirect_to @analysis, notice: "Analysis was successfully updated." }
        format.json { render :show, status: :ok, location: @analysis }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @analysis.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @analysis.destroy
    respond_to do |format|
      format.html { redirect_to analyses_url, notice: "Analysis was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_analysis
      @analysis = Analysis.find(params[:id])
    end

    def analysis_params
      params.require(:analysis).permit(:store_id,:date)
    end
end
