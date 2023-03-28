class TastingsController < ApplicationController
  before_action :set_tasting, only: %i[ show edit update destroy ]

  def index
    date = (Date.parse(params[:date]) + 1)
    @wednesday = date.prev_occurring(:wednesday)
    @prev_wednesday = @wednesday - 7
    @next_wednesday = @wednesday + 7
    daily_menus = DailyMenu.where(start_time:@wednesday..@wednesday+6)
    product_ids = DailyMenuDetail.where(daily_menu_id:daily_menus.ids).map{|dmd|dmd.product_id}.uniq
    @products = Product.where(id:product_ids).order(:product_category)
    @product_tasting_count = Tasting.where(product_id:product_ids).group(:product_id).count
  end

  def show
  end

  def new
    @product = Product.find(params[:product_id])
    @tasting = Tasting.new(product_id:params[:product_id],sell_price:@product.sell_price)
    store_ids = Store.where(group_id:9)
    @staffs = Staff.where(employment_status:1,store_id:store_ids,status:0)
  end

  def edit
    @product = @tasting.product
    store_ids = Store.where(group_id:9)
    @staffs = Staff.where(employment_status:1,store_id:store_ids,status:0)
  end

  def create
    @tasting = Tasting.new(tasting_params)

    respond_to do |format|
      if @tasting.save
        format.html { redirect_to tasting_url(@tasting), notice: "Tasting was successfully created." }
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
      format.html { redirect_to tastings_url, notice: "Tasting was successfully destroyed." }
      format.json { head :no_content }
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