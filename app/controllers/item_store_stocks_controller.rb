class ItemStoreStocksController < ApplicationController
  before_action :set_item_store_stock, only: %i[ show edit update destroy ]

  def stores
    @stores = current_user.group.stores
    
  end
  def index
    store_id = params[:store_id]
    date = params[:date]
    @item_store_stocks = ItemStoreStock.where(date:date,store_id:store_id)
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
        format.js
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @item_store_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    stock = params[:item_store_stock][:stock].to_f
    stock_price = (stock * @item_store_stock.unit_price).floor(1)
    respond_to do |format|
      if @item_store_stock.update(item_store_stock_params.merge(stock_price: stock_price))
        date = @item_store_stock.date
        store_id = @item_store_stock.store_id
        format.html { redirect_to stocks_items_path(date:date,store_id:store_id), notice: "Item store stock was successfully updated." }
        format.js
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
      params.require(:item_store_stock).permit(:stock)
    end
end
