class ProductsController < ApplicationController
  def index
    @search = Product.search(params).page(params[:page]).per(20)
  end

  def new
    @product = Product.new
    @product.product_menus.build
  end
  def show
   @product = Product.find(params[:id])
   @product_menus = @product.product_menus
   @menus = @product.menus
 end

  def create
    Product.create(product_params)
    redirect_to products_path
  end

  def edit
    @product = Product.find(params[:id])
  end

  def update
    product = Product.find(params[:id])
    product.update(product_params2)
  end

  private
  def product_params
    params.require(:product).permit(:name, :cook_category, :product_type, :sell_price, :description, :contents,
                    product_menus_attributes: [:id, :product_id, :menu_id, :_destroy,
                    menu_attributes:[:name, ]])
  end
  def product_params2
    params.permit(:name, :cook_category, :product_type, :sell_price, :description, :contents,
                    product_menus_attributes: [:id, :product_id, :menu_id, :_destroy,
                    menu_attributes:[:name, ]])
  end


end
