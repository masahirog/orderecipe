class OrdersController < ApplicationController

  def confirm
      @hash = Material.calculate_products_materials(params)
  end

  def new
    @products = Product.all
  end

  def order_print
    render :order_print, layout: false #このページでlayoutを適用させない
  end
end
