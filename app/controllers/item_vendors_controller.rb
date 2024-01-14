class ItemVendorsController < ApplicationController
  before_action :set_item_vendor, only: %i[ show edit update destroy ]

  def index
    @item_vendors = ItemVendor.all
  end

  def show
  end

  def new
    @item_vendor = ItemVendor.new
  end

  def edit
  end

  def create
    @item_vendor = ItemVendor.new(item_vendor_params)

    respond_to do |format|
      if @item_vendor.save
        format.html { redirect_to item_vendor_url(@item_vendor), notice: "Item vendor was successfully created." }
        format.json { render :show, status: :created, location: @item_vendor }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @item_vendor.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @item_vendor.update(item_vendor_params)
        format.html { redirect_to item_vendor_url(@item_vendor), notice: "Item vendor was successfully updated." }
        format.json { render :show, status: :ok, location: @item_vendor }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @item_vendor.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @item_vendor.destroy

    respond_to do |format|
      format.html { redirect_to item_vendors_url, notice: "Item vendor was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_item_vendor
      @item_vendor = ItemVendor.find(params[:id])
    end

    def item_vendor_params
      params.require(:item_vendor).permit(:store_name,:producer_name,:area,:payment,:bank_name,:bank_store_name,:bank_category,:account_number,
        :account_title,:zip_code,:address,:tel,:charge_person,:unused_flag)
    end
end
