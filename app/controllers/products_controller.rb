class ProductsController < ApplicationController
  protect_from_forgery :except => [:henkan]
  require 'net/https'
  require 'json'

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

  def get_products
    @products = Product.where(['bento_id LIKE ?', "%#{params["id"]}%"]).limit(10)
    respond_to do |format|
      format.html
      format.json { render 'index', json: @products }
    end
  end
  def input_name_get_products
    @products = Product.where(['name LIKE ?', "%#{params["id"]}%"]).limit(10)
    respond_to do |format|
      format.html
      format.json { render 'index', json: @products }
    end
  end

  def index
    @search = Product.includes(:product_menus,{menus: [:menu_materials,:materials]}).search(params).page(params[:page]).per(20)
  end

  def new
    @bento_id = Product.bentoid()
    @product = Product.new
    @product.product_menus.build
  end

  def show
  @product = Product.includes(:product_menus,{menus: [:menu_materials, {materials: [:vendor]}]}).find(params[:id])
  @allergies = Product.allergy_seiri(@product)
  @additives = Product.additive_seiri(@product)
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "#{@product.id}_#{Time.now.strftime('%Y%m%d')}.csv", type: :csv
      end
    end
  end
  def show_all
  @products = Product.all.includes(:product_menus,{menus: [:menu_materials, :materials]})
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "all_products.csv", type: :csv
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
    @bento_id = Product.bentoid()
    @product = Product.includes(:product_menus,{menus: [:menu_materials,:materials]}).find(params[:id])
    @product.product_menus.build  if @product.menus.length == 0
    @allergies = Product.allergy_seiri(@product)
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

  def serving_detail_en
    @product = Product.find(params[:id])
    @menus = @product.menus.includes(:materials, :menu_materials)
    render :serving_detail_en, layout: false
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
    @order = Order.includes({products: {menus: :menu_materials, menus: :materials}}).find(params[:id])
    @order_products = @order.order_products
    respond_to do |format|
     format.html
     format.pdf do
       pdf = PreparationPdf.new(@order,@order_products)
       send_data pdf.render,
       filename:    "preparation_all.pdf",
       type:        "application/pdf",
       disposition: "inline"
     end
   end
  end

  def product_pdf_all
    @order = Order.includes({products: {menus: :menu_materials, menus: :materials}}).find(params[:id])
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

  def henkan
    sentence = params["kanji"]
    app_id = "6e84997fe5d4d3865152e765091fd0faab2f76bfe5dba29d638cc6683efa1184"
    request_data = {'app_id'=>app_id, "sentence"=>sentence}.to_json
    header = {'Content-type'=>'application/json'}
    https = Net::HTTP.new('labs.goo.ne.jp', 443)
    https.use_ssl=true
    response = https.post('/api/morph', request_data, header)
    if JSON.parse(response.body)["word_list"].present?
      @result = JSON.parse(response.body)["word_list"]
    end
    respond_to do |format|
      format.html
      format.json
    end
  end

  def hyoji
    @product = Product.find(params[:id])
    @allergies = Product.allergy_seiri(@product)
    @additives = Product.additive_seiri(@product)
    respond_to do |format|
     format.html
     format.pdf do
       pdf = HyojiPdf.new(@product,params[:datetime_ida],@allergies,@additives)
       send_data pdf.render,
         filename:    "#{@product.id}_shokuhinhyoji.pdf",
         type:        "application/pdf",
         disposition: "inline"
     end
   end
  end
  private
    def product_create_update
      params.require(:product).permit(:name, :bento_id, :cook_category, :product_type, :sell_price, :description, :contents, :product_image,
                      :remove_product_image, :image_cache, :cost_price, product_menus_attributes: [:id, :product_id, :menu_id, :_destroy,
                      menu_attributes:[:name, ]])
    end
end
