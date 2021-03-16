class ProductsController < AdminController
  require 'net/https'
  require 'json'

  def get_menu
    @menus = Menu.where("name LIKE ?", "%#{params[:q]}%").first(10)
    respond_to do |format|
      format.json { render json: @menus }
    end
  end

  def get_product
    @product = Product.find(params[:product_id])
    respond_to do |format|
      format.html
      format.json { render json: { bejihan_sozai_flag: @product.bejihan_sozai_flag } }
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
    @products = Product.where(['management_id LIKE ?', "%#{params["id"]}%"]).limit(10)
    @product_hash = {}
    @products.each_with_index do |product,i|
      cost_rate = ((product.cost_price / product.sell_price)*100).round
      @product_hash[i]= {name:product.name,product_id:product.id,management_id:product.management_id,brand:product.brand.name,image:product.image,
        sell_price:product.sell_price,cost_price:product.cost_price,cost_rate:cost_rate}
    end
    respond_to do |format|
      format.html
      format.json { render 'index', json: @product_hash }
    end
  end
  def input_name_get_products
    @products = Product.includes(:brand).where(['name LIKE ?', "%#{params["id"]}%"]).limit(10)
    @product_hash = {}
    @products.each_with_index do |product,i|
      cost_rate = ((product.cost_price / product.sell_price)*100).round
      @product_hash[i]= {name:product.name,product_id:product.id,management_id:product.management_id,brand:product.brand.name,image:product.image,
        sell_price:product.sell_price,cost_price:product.cost_price,cost_rate:cost_rate}
    end

    respond_to do |format|
      format.html
      format.json { render 'index', json: @product_hash }
    end
  end

  def index
    @search = Product.includes(:brand,:order_products,:daily_menu_details,:kurumesi_order_details).search(params).page(params[:page]).per(30)
  end

  def new
    if params[:copy_flag]=='true'
      original_product = Product.includes(product_menus:[menu:[menu_materials:[:material]]]).find(params[:product_id])
      original_product.name = "#{original_product.name}のコピー"
      @product = original_product.deep_clone(include: [:product_menus])
      flash.now[:notice] = "#{original_product.name}を複製しました。この商品を登録する前に、コピーした元の商品のmanagement_idを消してください。名前も変更してください。"
      @menus = original_product.menus
    else
      @management_id = Product.bentoid()
      @product = Product.new(sell_price:0,brand_id:111)
      @product.product_menus.build(row_order: 0)
      @menus = []
    end
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


  def create
    @product = Product.new(product_create_update)
    if @product.save
      redirect_to products_path
    else
      menu_ids = []
      params["product"]["product_menus_attributes"].each{|key,value|menu_ids << value['menu_id']}
      @menus = Menu.where(id:menu_ids)
      render 'new'
    end
  end

  def edit
    @management_id = Product.bentoid()
    @product = Product.includes(:product_menus,{menus: [:menu_materials,:materials]}).find(params[:id])
    @product.product_pops.build
    @menus = @product.menus
    @product.product_menus.build  if @product.menus.length == 0
    @allergies = Product.allergy_seiri(@product)

  end

  def update
    @product = Product.find(params[:id])
    if @product.update(product_create_update)
      redirect_to product_path
    else
      menu_ids = []
      params["product"]["product_menus_attributes"].each{|key,value|menu_ids << value['menu_id']}
      @menus = Menu.where(id:menu_ids)
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

  def serving
    @product = Product.find(params[:id])
    @menus = @product.menus.includes(:materials, :menu_materials)
    render :serving_kana, layout: false
  end


  # def recipe_romaji
  #   @product = Product.find(params[:id])
  #   @menus = @product.menus.includes(:materials, :menu_materials)
  #   menu_names = ""
  #   cook_the_day_befores = ""
  #   material_names = ""
  #   posts = ""
  #   preparations = ""
  #   @menus.each do |menu|
  #     menu_names += menu.name + "^^"
  #     cook_the_day_befores += menu.cook_the_day_before + "^^"
  #     menu.menu_materials.each do |mmm|
  #       material_names += mmm.material.name + "^^"
  #       posts += mmm.post + "^^"
  #       preparations += mmm.preparation + "^^"
  #     end
  #   end
  #   @product.name = Romaji.kana2romaji Product.make_katakana(@product.name)[0]
  #   @menu_names = Product.make_katakana(menu_names)
  #   @menu_cook_the_day_befores = Product.make_katakana(cook_the_day_befores)
  #   @material_names = Product.make_katakana(material_names)
  #   @posts = Product.make_katakana(posts)
  #   @preparations = Product.make_katakana(preparations)
  #   ii=0
  #   @menus.each_with_index do |menu,i|
  #     menu.name = Romaji.kana2romaji @menu_names[i]
  #     menu.cook_the_day_before = Romaji.kana2romaji @menu_cook_the_day_befores[i] if @menu_cook_the_day_befores[i]
  #     menu.menu_materials.each do |mmm|
  #       mmm.material.name = Romaji.kana2romaji @material_names[ii]
  #       mmm.post = Romaji.kana2romaji @posts[ii] if @posts[ii]
  #       mmm.preparation = Romaji.kana2romaji @preparations[ii] if @preparations[ii]
  #       ii += 1
  #     end
  #   end
  #   render :recipe_romaji, layout: false
  # end

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
  def print_preparation
    @params = params
    @product = Product.find(params[:volume][:id])
    @menus = @product.menus.includes(:materials, :menu_materials)
    respond_to do |format|
      format.html
      format.pdf do
        pdf = ShogunPreparation.new(@params,@product,@menus)
        send_data pdf.render,
        filename:    "#{@product.name}_#{params[:volume][:num]}shoku.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
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

  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_path, notice: '商品を削除しました。' }
      format.json { head :no_content }
    end
  end
  def bejihan_ss_cost_sync
    Product.input_spreadsheet
    redirect_to products_path, notice: 'スプレッドシートに連携しました！'
  end


  private
    def product_create_update
      params.require(:product).permit(:name,:memo, :management_id,:short_name,:symbol, :sell_price, :description, :contents, :image,:brand_id,:product_category,:bejihan_sozai_flag,
                      :food_label_name,:food_label_content,:status,:remove_image, :image_cache,:display_image,:image_for_one_person,:serving_infomation,
                      :cost_price,:cooking_rice_id, product_menus_attributes: [:id, :product_id, :menu_id,:row_order, :_destroy],product_pops_attributes: [:id, :product_id,:image])
    end
end
