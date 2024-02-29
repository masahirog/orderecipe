class ItemStoreStocksController < ApplicationController
  before_action :set_item_store_stock, only: %i[ show edit update destroy ]

  def stores
    @stores = current_user.group.stores
    
  end
  def index
    store_id = params[:store_id]
    date = params[:date]
    @item_store_stocks = ItemStoreStock.where(date:date,store_id:store_id)
    binding.pry
  end

  def show
  end

  def new
    @item_store_stock = ItemStoreStock.new
  end

  def edit
  end

  def create
    @item_store_stock = ItemStoreStock.new(item_store_stock_params)

    respond_to do |format|
      if @item_store_stock.save
        format.html { redirect_to item_store_stock_url(@item_store_stock), notice: "Item store stock was successfully created." }
        format.json { render :show, status: :created, location: @item_store_stock }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @item_store_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @item_store_stock.update(item_store_stock_params)
        format.html { redirect_to item_store_stock_url(@item_store_stock), notice: "Item store stock was successfully updated." }
        format.json { render :show, status: :ok, location: @item_store_stock }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @item_store_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @item_store_stock.destroy

    respond_to do |format|
      format.html { redirect_to item_store_stocks_url, notice: "Item store stock was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_item_store_stock
      @item_store_stock = ItemStoreStock.find(params[:id])
    end

    def item_store_stock_params
      params.fetch(:item_store_stock, {})
    end
end
