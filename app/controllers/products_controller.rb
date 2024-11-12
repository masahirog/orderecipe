class ProductsController < ApplicationController
  require 'net/https'
  require 'json'
  require 'open-uri'

  def label
    @product = Product.find(params[:id])
    if params[:format] == 'csv'
      @label_name = params[:label_name]
      @number = params[:print_number].to_i
      @sell_price = params[:sell_price]
      @tax_including_sell_price = params[:tax_including_sell_price]
    end
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "#{@product.food_label_name}.csv", type: :csv
      end
    end
  end


  def include_menu
    @product_menus = ProductMenu.includes(:product).where(menu_id: params[:id]).page(params[:page]).per(20)
    menu = Menu.find(params[:id])
    @menus = Menu.all
  end



  def store_price_card
    if params["store_daily_menu_ids"].present?
      store_daily_menu_ids = params["store_daily_menu_ids"].values
    end
    respond_to do |format|
      format.html
      format.pdf do
        pdf = StorePriceCard.new(store_daily_menu_ids)
        send_data pdf.render,
        filename:    "price_card.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end


  def price_card
    dmd_ids = params[:dmd_ids].values.reject(&:blank?)
    products = []
    # daily_menu_detailsの価格を優先する、dmd_idsをeachで回さないと重複が削除される
    dmd_ids.each do |id|
      dmd = DailyMenuDetail.find(id)
      product = dmd.product
      product.sell_price = dmd.sell_price
      product.tax_including_sell_price = (dmd.sell_price * 1.08).floor
      products << product
    end
    respond_to do |format|
      format.html
      format.pdf do
        pdf = PriceCard.new(products)
        send_data pdf.render,
        filename:    "price_card.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end

  def edit_bb
    @product = Product.find(params[:product_id])
    # @product.product_bbs.build
    staff_ids = StaffStore.joins(:store).where(:stores => {store_type:0,group_id:current_user.group_id}).map{|ss|ss.staff_id}.uniq
    @staffs = Staff.where(status:0,id:staff_ids).order(row:'asc')
  end
  def black_board
    @date = Date.parse(params[:date])
    @daily_menu = DailyMenu.find_by(start_time:@date)
    product_ids = DailyMenuDetail.joins(:daily_menu).where(:daily_menus => {id:@daily_menu.id}).map{|dmd|dmd.product_id}
    @products = Product.where(id:product_ids)
  end

  def get_menu
    @menus = Menu.where(group_id:current_user.group_id).where("name LIKE ?", "%#{params[:q]}%").first(20)
    respond_to do |format|
      format.json { render json: @menus }
    end
  end

  def get_product_select2
    @products = Product.where(brand_id:111,status:1).where("name LIKE ?", "%#{params[:q]}%").first(20)
    respond_to do |format|
      format.json { render json: @products }
    end
  end

  def get_product
    @product = Product.find(params[:product_id])
    respond_to do |format|
      format.html
      format.json { render json: { bejihan_sozai_flag: @product.bejihan_sozai_flag,sell_price:@product.sell_price } }
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

  def input_name_get_products
    @products = Product.includes(:brand).where(['name LIKE ?', "%#{params["id"]}%"]).limit(10)
    @product_hash = {}
    @products.each_with_index do |product,i|
      cost_rate = ((product.cost_price / product.sell_price)*100).round
      @product_hash[i]= {name:product.name,product_id:product.id,brand:product.brand.name,image:product.image,
        sell_price:product.sell_price,cost_price:product.cost_price,cost_rate:cost_rate}
    end
    respond_to do |format|
      format.html
      format.json { render 'index', json: @product_hash }
    end
  end

  def index
    @search = Product.includes(:brand,:order_products,:daily_menu_details,:container).search(params,current_user.group_id).page(params[:page]).per(30)
  end

  def new
    if current_user.group_id == 9
      @categories = Product.product_categories.find_all{|k,v| v < 13 || v > 18 }.to_h.keys
    else
      @categories = Product.product_categories.find_all{|k,v| v < 13 || v < 19 }.to_h.keys
    end
    @brands = Brand.where(group_id:current_user.group_id,unused_flag:false)
    if params[:copy_flag]=='true'
      original_product = Product.includes(product_menus:[menu:[menu_materials:[:material]]]).find(params[:product_id])
      flash.now[:notice] = "#{original_product.name}を複製しました。名前を変更してください。"
      original_product.name = "#{original_product.name}のコピー"
      original_product.smaregi_code = ""
      @product = original_product.deep_clone(include: [:product_menus,:product_parts,:product_ozara_serving_informations])
      @menus = original_product.menus
    else
      @product = Product.new(sell_price:0)
      @product.product_menus.build(row_order: 0)
      @menus = []
    end
  end

  def show
    @product = Product.includes(:product_menus,{menus: [:menu_processes,materials:[:food_ingredient],menu_materials:[:menu]]}).find(params[:id])
    @allergies = Product.allergy_seiri(@product)
    @additives = Product.additive_seiri(@product)
    order_products = @product.order_products
    daily_menu_details = @product.daily_menu_details
    unless order_products.present?||daily_menu_details.present?
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
    @brands = Brand.where(group_id:current_user.group_id,unused_flag:false)
    @product = Product.new(product_create_update)
    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, success: "作成！" }
      else
        menu_ids = []
        params["product"]["product_menus_attributes"].each{|key,value|menu_ids << value['menu_id']}
        @menus = Menu.where(id:menu_ids)
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    if current_user.group_id == 9
      @categories = Product.product_categories.find_all{|k,v| v < 13 || v > 18 }.to_h.keys
    else
      @categories = Product.product_categories.find_all{|k,v| v < 13 || v < 19 }.to_h.keys
    end
    @brands = Brand.where(group_id:current_user.group_id,unused_flag:false)
    @product = Product.includes(:product_menus,{menus: [:menu_materials,:materials]}).find(params[:id])
    @menus = @product.menus
    calorie = 0
    protein = 0
    lipid = 0
    carbohydrate = 0
    dietary_fiber = 0
    salt = 0
    @menus.each do |menu|
      calorie += menu.calorie
      protein += menu.protein
      lipid += menu.lipid
      carbohydrate += menu.carbohydrate
      dietary_fiber += menu.dietary_fiber
      salt += menu.salt
    end
    @product.calorie = calorie
    @product.protein = protein
    @product.lipid = lipid
    @product.carbohydrate = carbohydrate
    @product.dietary_fiber = dietary_fiber
    @product.salt = salt
    @product.product_menus.build  if @product.menus.length == 0
    @allergies = Product.allergy_seiri(@product)
    @data = ""
    @food_additives = ""
    allergy = Product.allergy_seiri(@product).join(",")
    if allergy.present?
      @allergy = "、(一部に#{allergy}を含む)"
    else
      @allergy = ""
    end
    @product.menus.each do |menu|
      if menu.category == "容器"
      else
        if @data.present?
          @data += "、【#{menu.food_label_name}】#{menu.food_label_contents}"
        else
          @data += "【#{menu.food_label_name}】#{menu.food_label_contents}"
        end
      end
    end
    fas = FoodAdditive.where(id:@product.menus.map{|menu|menu.used_additives}.flatten.reject(&:blank?).uniq).map{|fa|fa.name}.join("、")
    if fas.present?
      @food_additives += "／#{fas}"
    else
      @food_additives += ""
    end
  end

  def update
    @brands = Brand.where(group_id:current_user.group_id,unused_flag:false)
    @product = Product.find(params[:id])
    respond_to do |format|
      if @product.update(product_create_update)
        if  params[:product][:edit_bb].present?
          format.html { redirect_to black_board_products_path(date:@today), success: "更新！" }
        else
          format.html { redirect_to @product, success: "更新！" }
        end
      else
        menu_ids = []
        params["product"]["product_menus_attributes"].each{|key,value|menu_ids << value['menu_id']}
        @menus = Menu.where(id:menu_ids)
        format.html { render :edit, status: :unprocessable_entity }
      end
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
      format.html { redirect_to products_path, success: '商品を削除しました。' }
      format.json { head :no_content }
    end
  end

  def download
    product = Product.find(params[:id])
    data = URI.open(product.image.url)
    send_data(data.read, type:product.image.file.content_type, filename: product.image.file.filename)
  end

  private
    def product_create_update
      params.require(:product).permit(:name,:memo, :sell_price, :description, :contents, :image,:brand_id,:product_category,:bejihan_sozai_flag,
                      :group_id,:sub_category,:reduced_tax_flag,:half_able_flag,
                      :food_label_name,:food_label_content,:status,:remove_image,:remove_image_for_one_person, :image_cache,:display_image,:image_for_one_person,:serving_infomation,:carryover_able_flag,
                      :main_serving_plate_id,:sub_serving_plate_id,:container_id,:ozara_serving_infomation,:freezing_able_flag,:bejihan_only_flag,
                      :smaregi_code,:warm_flag,:tax_including_sell_price,:sales_unit,:calorie,:protein,:lipid,:carbohydrate,:dietary_fiber,:salt,
                      :cost_price, product_menus_attributes: [:id, :product_id, :menu_id,:row_order, :_destroy],
                    product_parts_attributes: [:id,:product_id,:name,:amount,:unit, :_destroy,:memo,:container,:sticker_print_flag,:common_product_part_id,:loading_container,:loading_position],
                    product_ozara_serving_informations_attributes: [:id, :product_id,:row_order,:content,:image, :_destroy],
                    product_pack_serving_informations_attributes: [:id, :product_id,:row_order,:content,:image, :_destroy],
                    product_bbs_attributes: [:id,:product_id,:image,:memo,:staff_id, :remove_image,:_destroy])
    end
end
