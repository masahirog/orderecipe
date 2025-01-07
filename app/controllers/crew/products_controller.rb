class Crew::ProductsController < ApplicationController
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
    @store_daily_menu_details = @store_daily_menu.store_daily_menu_details.includes(product:[:container,:product_ozara_serving_informations,:product_pack_serving_informations])
    products = @store_daily_menu.products
    sozai_ids = products.where(product_category:"惣菜").ids
    bento_ids = products.where(product_category:"お弁当").ids
    @bento_shokusu = @store_daily_menu_details.where(product_id:bento_ids).map{|sdmd|sdmd.sozai_number}.sum
    @sozai_shokusu = @store_daily_menu_details.where(product_id:sozai_ids).map{|sdmd|sdmd.sozai_number}.sum
  end

  def show
    @product = Product.find(params[:id])
  end

end
