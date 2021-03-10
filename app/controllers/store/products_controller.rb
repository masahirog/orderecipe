class Store::ProductsController < ApplicationController

  def index
    @search = Product.includes(:brand,:order_products,:daily_menu_details,:kurumesi_order_details).search(params).page(params[:page]).per(30)
  end


  def show
    @product = Product.includes(:product_menus,{menus: [:menu_materials, :materials]}).find(params[:id])
    @allergies = Product.allergy_seiri(@product)
    @additives = Product.additive_seiri(@product)
    order_products = @product.order_products
    daily_menu_details = @product.daily_menu_details
    kurumesi_order_details = @product.kurumesi_order_details
    unless order_products.present?||daily_menu_details.present?||kurumesi_order_details.present?
      @delete_flag = true
    end
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "#{Time.now.strftime('%Y%m%d')}_product_#{@product.id}.csv", type: :csv
      end
    end
  end
end
