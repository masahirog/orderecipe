class ProductsController < ApplicationController
  def get_menu_cost_price
    @menu = Menu.includes(:menu_materials,:materials).find(params[:id])
    # binding.pry
    respond_to do |format|
      format.html
      format.json
    end
  end

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
   @menus = @product.menus.includes(:materials, :menu_materials)
  end

  def create
    @product = Product.create(product_create_update)
    if @product.save
      redirect_to products_path
    else
      render 'new'
    end
  end

  def edit
    @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])
    @product.update(product_create_update)
    if @product.save
      redirect_to products_path
    else
      render 'edit'
    end

  end

  private
    def product_create_update
      params.require(:product).permit(:name, :cook_category, :product_type, :sell_price, :description, :contents, :product_image,
                      :remove_product_image, :image_cache, :cost_price, product_menus_attributes: [:id, :product_id, :menu_id, :_destroy,
                      menu_attributes:[:name, ]])
    end
end
