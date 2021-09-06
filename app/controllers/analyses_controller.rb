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
    total_loass_amount = 0
    analysis_id = params[:analysis]["analysis_id"]
    @analysis = Analysis.find(analysis_id)
    smaregi_trading_histories = SmaregiTradingHistory.where(analysis_id:analysis_id)

    update_analysis_products = []
    @product_sales_number = smaregi_trading_histories.group(:shohin_id).sum(:suryo)
    @product_sales_amount = smaregi_trading_histories.group(:shohin_id).sum(:nebikigokei)
    @analysis.analysis_products.each do |ap|
      ap.sales_number = @product_sales_number[ap.smaregi_shohin_id]
      ap.total_sales_amount = @product_sales_amount[ap.smaregi_shohin_id]
      if ap.manufacturing_number.present? && ap.sales_number.present?
        ap.loss_number = ap.manufacturing_number - ap.sales_number
        loss_amount = ap.list_price * ap.loss_number
        if loss_amount < 0 || ap.product_id == 10459
          ap.loss_amount = 0
        else
          ap.loss_amount = loss_amount
          total_loass_amount += loss_amount
        end
      else
        ap.loss_number = 0
        ap.loss_amount = 0
        total_loass_amount += 0
      end
      update_analysis_products << ap
    end
    AnalysisProduct.import update_analysis_products, on_duplicate_key_update:[:sales_number,:loss_number,:total_sales_amount,:loss_amount]
    @analysis.update(loss_amount:total_loass_amount)
    redirect_to @analysis
  end
  def products
    #データ検証の商品情報を更新する
    analysis_id = params[:analysis]["analysis_id"]
    @analysis = Analysis.find(analysis_id)
    # smaregi_trading_histories = SmaregiTradingHistory.where(analysis_id:analysis_id)
    @store_daily_menu = StoreDailyMenu.find_by(start_time:@analysis.date,store_id:@analysis.store_id)
    store_daily_menu_details_arr = []
    update_store_daily_menu_details_arr = []
    @store_daily_menu.store_daily_menu_details.each do |sdmd|
      analysis_products = @analysis.analysis_products.where(product_id:sdmd.product_id)
      if analysis_products.length > 1
        analysis_products.each do |analysis_product|
          analysis_product.list_price = 0
          analysis_product.manufacturing_number = 0
          update_store_daily_menu_details_arr << analysis_product
        end
      elsif analysis_products.length == 1
        analysis_product = analysis_products[0]
        analysis_product.list_price = sdmd.product.sell_price
        analysis_product.manufacturing_number = sdmd.actual_inventory
        update_store_daily_menu_details_arr << analysis_product
      else
        new_store_daily_menu_detail = AnalysisProduct.new(analysis_id:analysis_id,product_id:sdmd.product_id,list_price:sdmd.product.sell_price,manufacturing_number:sdmd.number)
        store_daily_menu_details_arr << new_store_daily_menu_detail
      end
    end
    AnalysisProduct.import store_daily_menu_details_arr
    AnalysisProduct.import update_store_daily_menu_details_arr, on_duplicate_key_update:[:list_price,:manufacturing_number] if update_store_daily_menu_details_arr
    redirect_to @analysis
  end
  def date
    @date = params[:date]
    @stores = Store.all
    @analyses_hash = {}
    Analysis.where(date:@date).each do |analysis|
      @analyses_hash[analysis.store_id] = analysis.id
    end

  end
  def index
    if params[:from]
      @from = params[:from]
    else
      @from = Date.today.beginning_of_month
    end
    if params[:to]
      @to = params[:to]
    else
      @to = @from.end_of_month
    end
  end

  def show
    @or_ari_analysis_products = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @or_nashi_analysis_products = []
    @smaregi_trading_histories = @analysis.smaregi_trading_histories.page(params[:page]).per(50)
    date = @analysis.date
    store_id = @analysis.store_id
    store_daily_menu = StoreDailyMenu.find_by(start_time:date,store_id:store_id)
    @store_daily_menu_details = store_daily_menu.store_daily_menu_details.order(:row_order)
    sdmd_arr = store_daily_menu.store_daily_menu_details.includes([:product]).map{|sdmd|sdmd.product_id}
    @analysis.analysis_products.includes([:product]).each do |ap|
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
