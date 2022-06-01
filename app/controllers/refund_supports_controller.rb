class RefundSupportsController < ApplicationController
  before_action :set_refund_support, only: %i[ show edit update destroy ]

  def index
    @store = Store.find(params[:store_id])
    @refund_supports = RefundSupport.where(store_id:params[:store_id])
  end

  def show
  end

  def new
    @refund_support = RefundSupport.new(store_id:params[:store_id],occurred_at:Time.now,status:0,content:'お客様名：'+"\n"+'状況：'+"\n"+'行うべき事：')
  end

  def edit
  end

  def create
    @refund_support = RefundSupport.new(refund_support_params)

    respond_to do |format|
      if @refund_support.save
        format.html { redirect_to refund_supports_path(store_id:@refund_support.store_id), notice: "作成しました。" }
        format.json { render :show, status: :created, location: @refund_support }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @refund_support.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @refund_support.update(refund_support_params)
        format.html { redirect_to refund_supports_path(store_id:@refund_support.store_id), notice: "更新しました。" }
        format.json { render :show, status: :ok, location: @refund_support }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @refund_support.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @refund_support.destroy
    respond_to do |format|
      format.html { redirect_to refund_supports_url, notice: "Refund support was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_refund_support
      @refund_support = RefundSupport.find(params[:id])
    end

    def refund_support_params
      params.require(:refund_support).permit(:occurred_at,:store_id,:status,:staff_name,:content,:visit_date)
    end
end
