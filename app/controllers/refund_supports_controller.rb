class RefundSupportsController < AdminController
  before_action :set_refund_support, only: %i[ show edit update destroy ]

  def index
    @store = Store.find(params[:store_id])
    if params[:status].present?
      @refund_supports = RefundSupport.where(status:params[:status],store_id:params[:store_id]).order("occurred_at DESC")
    else
      @refund_supports = RefundSupport.where(store_id:params[:store_id]).order("occurred_at DESC")
    end
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
        message = "返金対応のリストに1件追加されました。\n"+
        "店舗名：#{@refund_support.store.name}\n"+
        "発生日時：#{@refund_support.occurred_at.strftime("%Y/%-m/%-d (#{%w(日 月 火 水 木 金 土)[@refund_support.occurred_at.wday]})")}\n"+
        "状況： #{t("enums.refund_support.status.#{@refund_support.status}")}\n" +
        "対応者：#{@refund_support.staff_name}\n"+
        "内容："+
        "#{@refund_support.content}"
        Slack::Notifier.new("https://hooks.slack.com/services/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", username: 'Bot', icon_emoji: ':male-farmer:').ping(message)
        format.html { redirect_to refund_supports_path(store_id:@refund_support.store_id), success: "作成しました。" }
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
        format.html { redirect_to refund_supports_path(store_id:@refund_support.store_id), success: "更新しました。" }
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
