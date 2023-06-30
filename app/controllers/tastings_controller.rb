class TastingsController < ApplicationController
  before_action :set_tasting, only: %i[ show edit update destroy ]
  def weekly
    if params[:date].present?
      date = (Date.parse(params[:date]) + 1)
    else
      date = Date.today + 1
    end
    @wednesday = date.prev_occurring(:wednesday)
    @prev_wednesday = @wednesday - 7
    @next_wednesday = @wednesday + 7
    daily_menus = DailyMenu.where(start_time:@wednesday..@wednesday+6)
    product_ids = DailyMenuDetail.where(daily_menu_id:daily_menus.ids).map{|dmd|dmd.product_id}.uniq
    @products = Product.where(id:product_ids).order(:product_category)
    @product_tasting_count = Tasting.where(product_id:product_ids).group(:product_id).count    
  end

  def index
    if params[:product_id]
      @product = Product.find(params[:product_id])
      @tastings = @product.tastings.includes([:product])
    elsif params[:staff_id]
      @staff = Staff.find(params[:staff_id])
      @tastings = @staff.tastings.includes([:product])
    end
  end

  def show
  end

  def new
    @product = Product.find(params[:product_id])
    @tasting = Tasting.new(product_id:params[:product_id],sell_price:@product.sell_price)
    store_ids = Store.where(group_id:current_user.group_id)
    @staffs = Staff.where(store_id:store_ids,status:0)
  end

  def edit
    @product = @tasting.product
    store_ids = Store.where(group_id:current_user.group_id)
    @staffs = Staff.where(store_id:store_ids,status:0)
  end

  def create
    @tasting = Tasting.new(tasting_params)

    respond_to do |format|
      if @tasting.save
        message = "_新規試食コメント！_\n"+
        "日付：#{@tasting.date.strftime('%m月 %d日')}\n"+
        "商品：#{@tasting.product.name}　#{@tasting.product.sell_price}円\n"+
        "見た目（1〜4）：#{@tasting.appearance}\n"+
        "味（1〜4）：#{@tasting.taste}\n"+
        "価格納得感（1〜4）：#{@tasting.price_satisfaction}\n"+
        "総合評価（1〜4）：#{@tasting.total_evaluation}\n"+
        "コメント：\n#{@tasting.comment}\n"+
        "ーーーー"
        attachment_image = {
          image_url: @tasting.image.url
        }
        Slack::Notifier.new("https://hooks.slack.com/services/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", username: '試食', icon_emoji: ':man-surfing:', attachments: [attachment_image]).ping(message)
        format.html { redirect_to weekly_tastings_path(date:@tasting.date), notice: "Tasting was successfully created." }
        format.json { render :show, status: :created, location: @tasting }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @tasting.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @tasting.update(tasting_params)
        format.html { redirect_to tasting_url(@tasting), notice: "Tasting was successfully updated." }
        format.json { render :show, status: :ok, location: @tasting }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @tasting.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @tasting.destroy
    respond_to do |format|
      if params["product_id"].present?
        format.html { redirect_to tastings_path(product_id:params["product_id"]),notice: "試食コメントを削除しました" }
      else
        format.html { redirect_to tastings_path(staff_id:params["staff_id"]), notice: "試食コメントを削除しました" }
      end
    end
  end

  private
    def set_tasting
      @tasting = Tasting.find(params[:id])
    end

    def tasting_params
      params.require(:tasting).permit(:product_id,:staff_id,:date,:comment,:appearance,:taste,:amount,:likeness,:total_evaluation,:price_satisfaction,
        :sell_price,:image,:image_cache,:_destroy,:remove_image)
    end
end