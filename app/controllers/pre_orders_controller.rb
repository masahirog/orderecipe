class PreOrdersController < ApplicationController
  before_action :set_pre_order, only: %i[ show edit update destroy ]

  def index
    @pre_orders = PreOrder.all
  end

  def show
  end

  def new
    @pre_order = PreOrder.new
  end

  def edit
  end

  def create
    @pre_order = PreOrder.new(pre_order_params)

    respond_to do |format|
      if @pre_order.save
        format.html { redirect_to shibataya_orders_path(date:@pre_order.date), notice: "ご予約が完了しました。修正等の場合はお店までご連絡をお願いします。" }
        format.json { render :show, status: :created, location: @pre_order }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @pre_order.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @pre_order.update(pre_order_params)
        format.html { redirect_to '/shibataya', notice: "予約が完了しました。" }
        format.json { render :show, status: :ok, location: @pre_order }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @pre_order.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @pre_order.destroy

    respond_to do |format|
      format.html { redirect_to pre_orders_url, notice: "Pre order was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_pre_order
      @pre_order = PreOrder.find(params[:id])
    end

    def pre_order_params
      params.require(:pre_order).permit(:store_id,:date,:recipient_time,:employee_id,:recipient_name,:status,:memo,
                    pre_order_products_attributes: [:id,:pre_order_id,:product_id,:order_num,:_destroy])
    end
end

