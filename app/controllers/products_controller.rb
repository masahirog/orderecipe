class ProductsController < ApplicationController
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
    @search = Product.search(params).page(params[:page]).per(30)
  end

  def new
    if params[:copy_flag]=='true'
      original_product = Product.includes(product_menus:[menu:[menu_materials:[:material]]]).find(params[:product_id])
      original_product.name = "#{original_product.name}のコピー"
      @product = original_product.deep_clone(include: [:product_menus])
      flash.now[:notice] = "#{original_product.name}を複製しました。この商品を登録する前に、コピーした元の商品のbento_idを消してください。名前も変更してください。"
    else
      @bento_id = Product.bentoid()
      @product = Product.new
      @product.product_menus.build(row_order: 0)
    end
  end

  def show
    @product = Product.includes(:product_menus,{menus: [:menu_materials, :materials]}).find(params[:id])
    @allergies = Product.allergy_seiri(@product)
    @additives = Product.additive_seiri(@product)
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "#{Time.now.strftime('%Y%m%d')}_product_#{@product.id}.csv", type: :csv
      end
    end
  end


  def create
    @product = Product.new(product_create_update)
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
    if @product.update(product_create_update)
      redirect_to product_path
    else
      render 'edit'
    end
  end

  def serving_kana
    @product = Product.find(params[:id])
    @menus = @product.menus.includes(:materials, :menu_materials)

    menu_names = ""
    serving_memos = ""
    material_names = ""
    @menus.each do |menu|
      menu_names += menu.name + "^^"
      serving_memos += menu.serving_memo + "^^"
      menu.menu_materials.each do |mmm|
        material_names += mmm.material.name + "^^"
      end
    end
    @product.name = Product.make_katakana(@product.name)
    @menu_names = Product.make_katakana(menu_names)
    @serving_memos = Product.make_katakana(serving_memos)
    @material_names = Product.make_katakana(material_names)
    ii=0
    @menus.each_with_index do |menu,i|
      menu.name = @menu_names[i]
      menu.serving_memo = @serving_memos[i] if @serving_memos[i]
      menu.menu_materials.each do |mmm|
        mmm.material.name = @material_names[ii]
        ii += 1
      end
    end
    render :serving_kana, layout: false
  end


  def recipe_romaji
    @product = Product.find(params[:id])
    @menus = @product.menus.includes(:materials, :menu_materials)

    menu_names = ""
    recipes = ""
    material_names = ""
    posts = ""
    preparations = ""
    @menus.each do |menu|
      menu_names += menu.name + "^^"
      recipes += menu.recipe + "^^"
      menu.menu_materials.each do |mmm|
        material_names += mmm.material.name + "^^"
        posts += mmm.post + "^^"
        preparations += mmm.preparation + "^^"
      end
    end
    @product.name = Romaji.kana2romaji Product.make_katakana(@product.name)[0]
    @menu_names = Product.make_katakana(menu_names)
    @menu_recipes = Product.make_katakana(recipes)
    @material_names = Product.make_katakana(material_names)
    @posts = Product.make_katakana(posts)
    @preparations = Product.make_katakana(preparations)
    ii=0
    @menus.each_with_index do |menu,i|
      menu.name = Romaji.kana2romaji @menu_names[i]
      menu.recipe = Romaji.kana2romaji @menu_recipes[i] if @menu_recipes[i]
      menu.menu_materials.each do |mmm|
        mmm.material.name = Romaji.kana2romaji @material_names[ii]
        mmm.post = Romaji.kana2romaji @posts[ii] if @posts[ii]
        mmm.preparation = Romaji.kana2romaji @preparations[ii] if @preparations[ii]
        ii += 1
      end
    end
    render :recipe_romaji, layout: false
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
  def print_test
    @params = params
    @product = Product.find(params[:volume][:id])
    @menus = @product.menus.includes(:materials, :menu_materials)
    respond_to do |format|
      format.html
      format.pdf do
        pdf = ProductPdfTest.new(@params,@product,@menus)
        send_data pdf.render,
        filename:    "#{@product.name}_#{params[:volume][:num]}shoku.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end
  def print_test_all
    @order = Order.includes({products: {menus: :menu_materials, menus: :materials}}).find(params[:id])
    respond_to do |format|
      format.html
      format.pdf do
        pdf = ProductPdfTestAll.new(@order)
        send_data pdf.render,
        filename:    "#{@order.id}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end


  # 食品表示
  # def hyoji
  #   @product = Product.find(params[:id])
  #   @allergies = Product.allergy_seiri(@product)
  #   @additives = Product.additive_seiri(@product)
  #   respond_to do |format|
  #    format.html
  #    format.pdf do
  #      pdf = HyojiPdf.new(@product,params[:datetime_ida],@allergies,@additives)
  #      send_data pdf.render,
  #        filename:    "#{@product.id}_shokuhinhyoji.pdf",
  #        type:        "application/pdf",
  #        disposition: "inline"
  #    end
  #  end
  # end

  def picture_book
    @products = Product.search(params).page(params[:page]).per(100)
  end


  def new_band
    product = Product.find(params[:id])
    respond_to do |format|
      format.html
      format.pdf do
        pdf = BandPdf.new(product)
        send_data pdf.render,
          filename:    "#{product.name}_obi.pdf",
          type:        "application/pdf",
          disposition: "inline"
       end
    end
  end
  private
    def product_create_update
      params.require(:product).permit(:name,:memo, :bento_id, :cook_category, :product_type, :sell_price, :description, :contents, :product_image,
                      :remove_product_image, :image_cache, :cost_price, product_menus_attributes: [:id, :product_id, :menu_id,:row_order, :_destroy,
                      menu_attributes:[:name, ]])
    end
end
