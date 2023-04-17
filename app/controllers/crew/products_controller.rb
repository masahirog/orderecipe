class Crew::ProductsController < ApplicationController
  def ikkatsu
    if params[:start_date].present?
      @date = Date.parse(params[:start_date])
    else
      @date = Date.today
    end
    @daily_menu = DailyMenu.find_by(start_time:@date)
    @daily_menu_details = @daily_menu.daily_menu_details
  end
  def index
    if params[:start_date].present?
      @date = Date.parse(params[:start_date])
    else
      @date = Date.today
    end
    @tommoroww = @date + 1
    @yesterday = @date - 1
    @store = Store.find(params[:store_id])
    @store_daily_menu = @store.store_daily_menus.find_by(start_time:@date)
    @store_daily_menu_details = @store_daily_menu.store_daily_menu_details.includes(product:[:container,:product_ozara_serving_informations])
    products = @store_daily_menu.products
    sozai_ids = products.where(product_category:"惣菜").ids
    bento_ids = products.where(product_category:"お弁当").ids
    @bento_shokusu = @store_daily_menu_details.where(product_id:bento_ids).map{|sdmd|sdmd.sozai_number}.sum
    @sozai_shokusu = @store_daily_menu_details.where(product_id:sozai_ids).map{|sdmd|sdmd.sozai_number}.sum
  end

  def show
    @product = Product.find(params[:id])
  end
  # def description_update
  #   @product = Product.find(params[:product_id])
  #   respond_to do |format|
  #     if @product.update_attribute(:description,params[:description])
  #       format.html { redirect_to "/crew/product/#{@product.id}", success: "商品特徴を更新しました！ありがとう！" }
  #       format.js
  #     else
  #       format.js
  #     end
  #   end
  # end

  def edit
    @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])
    if @product.update(product_create_update)
      redirect_to crew_product_path(@product)
    else
      render 'edit'
    end
  end


  private
    def product_create_update
      params.require(:product).permit(:sky_wholesale_price,:sky_image,:sky_serving_infomation)
    end
end
