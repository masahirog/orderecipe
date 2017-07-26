class ProductsController < ApplicationController
  def index
    @search = Product.search(params).page(params[:page]).per(20)
    @products = Product.all
  end

  def new
    @product = Product.new
  end
  def show
   @product = Product.find(params[:id])
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
    params.require(:product).permit(:product_id, :product_name, :cook_category, :product_type, :sell_price, :description, :contents)
  end
  def product_params2
    params.permit(:product_id, :product_name, :cook_category, :product_type, :sell_price, :description, :contents)
  end


end
