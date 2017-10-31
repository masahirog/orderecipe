class ProductsController < ApplicationController
  def get_by_category
    if params[:category].present?
      @menu = Menu.where(category:params["category"])
      respond_to do |format|
        format.html
        format.json
      end
    else
      @menu = Menu.all
    end
  end

  def get_menu_cost_price
    @menu = Menu.includes(:menu_materials,:materials).find(params[:id])
    @menu_materials_info = Menu.menu_materials_info(params)
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
  @menus = @product.menus.includes(:materials, :menu_materials)
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "hoge.csv", type: :csv
      end
    end
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
      redirect_to product_path
    else
      render 'edit'
    end
  end

  def serving_detail
    @product = Product.find(params[:id])
    @menus = @product.menus.includes(:materials, :menu_materials)
    render :serving_detail, layout: false
  end

  def print
    @params = params
    @product = Product.find(params[:volume][:id])
    @menus = @product.menus.includes(:materials, :menu_materials)
    respond_to do |format|
     format.html
     format.pdf do
       pdf = ProductPdf.new(@params,@product,@menus)
       send_data pdf.render,
         filename:    "#{@product.name}_#{params[:volume][:num]}shoku.pdf",
         type:        "application/pdf",
         disposition: "inline"
     end
   end
  end
  def preparation_all
    @order = Order.find(params[:id])
    respond_to do |format|
     format.html
     format.pdf do
       pdf = PreparationPdf.new(@order)
       send_data pdf.render,
       filename:    "preparation_all.pdf",
       type:        "application/pdf",
       disposition: "inline"
     end
   end
  end

  def product_pdf_all
    @order = Order.find(params[:id])
    respond_to do |format|
     format.html
     format.pdf do
       pdf = ProductPdfAll.new(@order)
       send_data pdf.render,
         filename:    "#{@order.id}.pdf",
         type:        "application/pdf",
         disposition: "inline"
     end
   end
  end

  private
    def product_create_update
      params.require(:product).permit(:name, :cook_category, :product_type, :sell_price, :description, :contents, :product_image,
                      :remove_product_image, :image_cache, :cost_price, product_menus_attributes: [:id, :product_id, :menu_id, :_destroy,
                      menu_attributes:[:name, ]])
    end
end
