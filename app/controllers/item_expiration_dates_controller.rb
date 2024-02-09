class ItemExpirationDatesController < ApplicationController
  before_action :set_item_expiration_date, only: %i[ show edit update destroy ]

  def index
    if params[:done_flag].present?
      @item_expiration_dates = ItemExpirationDate.includes(item:[:item_vendor]).where(done_flag:params[:done_flag]).order(:expiration_date)
    else
      @item_expiration_dates = ItemExpirationDate.all.includes(item:[:item_vendor]).order(:expiration_date)
    end
  end

  def show
  end

  def new
    @items = Item.includes(:item_vendor).all
    @item_expiration_date = ItemExpirationDate.new
  end

  def edit
    @items = Item.includes(:item_vendor).all
  end

  def create
    @item_expiration_date = ItemExpirationDate.new(item_expiration_date_params)

    respond_to do |format|
      if @item_expiration_date.save
        format.html { redirect_to item_expiration_dates_path, info: "更新しました。" }
        format.json { render :show, status: :created, location: @item_expiration_date }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @item_expiration_date.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @item_expiration_date.update(item_expiration_date_params)
        format.html { redirect_to item_expiration_dates_path, info: "更新しました。" }
        format.json { render :show, status: :ok, location: @item_expiration_date }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @item_expiration_date.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @item_expiration_date.destroy

    respond_to do |format|
      format.html { redirect_to item_expiration_dates_url, notice: "Item expiration date was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_item_expiration_date
      @item_expiration_date = ItemExpirationDate.find(params[:id])
    end

    def item_expiration_date_params
      params.require(:item_expiration_date).permit(:expiration_date,:item_id,:number,:notice_date,:done_flag,:memo)
    end
end
