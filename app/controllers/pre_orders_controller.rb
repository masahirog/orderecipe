class PreOrdersController < ApplicationController
  before_action :set_pre_order, only: %i[ show edit update destroy ]

  def index
    if params[:date]
      @date = Date.parse(params[:date])
    else
      @date = @today
    end
    if params[:store_id].present?
      @pre_orders = PreOrder.includes(:store,pre_order_products:[:product]).where(date:@date,store_id:params[:store_id]).order(:recipient_time)
    else
      @pre_orders = PreOrder.includes(:store,pre_order_products:[:product]).where(date:@date).order(:recipient_time)
    end
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
        shohin = ''
        @pre_order.pre_order_products.each do |pop|
          shohin += "#{pop.product.food_label_name}（#{number_to_currency(pop.product.sell_price, :unit => "￥", format: "%u%n")}）：#{pop.order_num}食\n"
        end
        detail = "店舗：#{@pre_order.store.short_name}\n"+
        "日付：#{@pre_order.date.strftime("%-m/%-d(#{%w(日 月 火 水 木 金 土)[@pre_order.date.wday]})")}\n"+
        "時間：#{@pre_order.recipient_time.strftime('%H:%M')}\n"+    
        "名前：#{@pre_order.recipient_name}\n"+
        "社員番号：#{@pre_order.employee_id}\n"+
        "電話番号：#{@pre_order.tel}\n"+
        "メモ：#{@pre_order.memo}\n"+
        "ー 商品 ー\n"+shohin
        #↓開発
        # Slack::Notifier.new("https://hooks.slack.com/services/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", username: 'Bot', icon_emoji: ':male-farmer:').ping("柴田屋社員の方から注文が入りました！\nーーー\n"+detail+"\nーーー")
        #↓本番
        # Slack::Notifier.new("https://hooks.slack.com/services/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", username: 'Bot', icon_emoji: ':male-farmer:').ping("柴田屋社員の方から注文が入りました！\nーーー\n"+detail+"\nーーー")

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
        if @pre_order.status_before_type_cast == 0
          @bg = '#ffccd5'
        elsif @pre_order.status_before_type_cast == 3 || @pre_order.status_before_type_cast == 4
          @bg = '#d3d3d3'
        else
          @bg = '#ffffff'
        end
        format.html { redirect_to '/shibataya', notice: "予約が完了しました。" }
        format.js
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.js
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
      params.require(:pre_order).permit(:store_id,:date,:recipient_time,:employee_id,:recipient_name,:status,:memo,:tel,:total,
                    pre_order_products_attributes: [:id,:pre_order_id,:product_id,:order_num,:tax_including_sell_price,:subtotal,:welfare_price,:employee_discount,:_destroy])
    end
end

