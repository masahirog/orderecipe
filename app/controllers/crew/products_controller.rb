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
    @daily_menu = DailyMenu.find_by(start_time:@date)
    @daily_menu_details = @daily_menu.daily_menu_details
  end
  def show
    @product = Product.find(params[:id])
  end
  def description_update
    @product = Product.find(params[:product_id])
    respond_to do |format|
      if @product.update_attribute(:description,params[:description])
        format.html { redirect_to "/crew/product/#{@product.id}", success: "商品特徴を更新しました！ありがとう！" }
        format.js
      else
        format.js
      end
    end
  end
end
