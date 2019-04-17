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


  def serving_detail_en
    @product = Product.find(params[:id])
    @menus = @product.menus.includes(:materials, :menu_materials)
    app_id = "6e84997fe5d4d3865152e765091fd0faab2f76bfe5dba29d638cc6683efa1184"
    header = {'Content-type'=>'application/json'}
    https = Net::HTTP.new('labs.goo.ne.jp', 443)
    https.use_ssl = true

    request_data = {'app_id'=>app_id, "sentence"=>@product.name}.to_json
    make_katakana(request_data,header,https)
    @product.name = Romaji.kana2romaji @katakana
    @menus.each do |menu|
      request_data = {'app_id'=>app_id, "sentence"=>menu.name}.to_json
      make_katakana(request_data,header,https)
      menu.name = Romaji.kana2romaji @katakana
      request_data = {'app_id'=>app_id, "sentence"=>menu.recipe}.to_json
      make_katakana(request_data,header,https)
      menu.recipe = Romaji.kana2romaji @katakana
      menu.menu_materials.each do |mm|
        request_data = {'app_id'=>app_id, "sentence"=>mm.material.name}.to_json
        make_katakana(request_data,header,https)
        mm.material.name = Romaji.kana2romaji @katakana
        request_data = {'app_id'=>app_id, "sentence"=>mm.post}.to_json
        make_katakana(request_data,header,https)
        mm.post = Romaji.kana2romaji @katakana
        request_data = {'app_id'=>app_id, "sentence"=>mm.preparation}.to_json
        make_katakana(request_data,header,https)
        mm.preparation = Romaji.kana2romaji @katakana
      end
    end
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


  #
  # def henkan
  #   arr = [params["kanji"],params["kanji0"],params[:kanji1].gsub(/\^\^  \^\^/, '^^a^^')]
  #   # sentence = params["kanji"]
  #   # sentence0 = params["kanji0"]
  #   # sentence1 = params["kanji1"]
  #   @data =[]
  #
  #   app_id = "6e84997fe5d4d3865152e765091fd0faab2f76bfe5dba29d638cc6683efa1184"
  #   header = {'Content-type'=>'application/json'}
  #   https = Net::HTTP.new('labs.goo.ne.jp', 443)
  #   https.use_ssl=true
  #   arr.each do |sentence|
  #     request_data = {'app_id'=>app_id, "sentence"=>sentence}.to_json
  #     response = https.post('/api/morph', request_data, header)
  #     if JSON.parse(response.body)["word_list"].present?
  #       result = JSON.parse(response.body)["word_list"]
  #     end
  #     katakana = ''
  #     result.flatten.in_groups_of(3).each do |ar|
  #       if ar[0]=='^^ '
  #         katakana += '^^'
  #       else
  #         if ar[2] == "＄"
  #           if ar[1]=='句点'
  #             katakana += "。"
  #           elsif ar[1]=='読点'
  #             katakana += "、"
  #           elsif ar[1]=='Number' || ar[0]=='-' || ar[1]=='括弧'
  #             katakana += ar[0]
  #           elsif ar[1]=='空白'
  #             katakana += ""
  #           end
  #         elsif ar[1]=="Alphabet"||ar[1]=="Number"
  #           katakana += ar[0]
  #         else
  #           katakana += ar[2]
  #         end
  #       end
  #     end
  #     romaji = Romaji.kana2romaji katakana
  #     @data << romaji.split("^^")
  #   end
  #   respond_to do |format|
  #     format.html
  #     format.json
  #   end
  # end

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

  def picture_book
    @products = Product.search(params).page(params[:page]).per(100)
  end

  def make_band

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
    def make_katakana(request_data,header,https)
      response = https.post('/api/morph', request_data, header)
      if JSON.parse(response.body)["word_list"].present?
        result = JSON.parse(response.body)["word_list"]
      end
      @katakana = ''
      if result.present?
        result.flatten.in_groups_of(3).each do |ar|
          if ar[2] == "＄"
            if ar[1] == '句点'
              @katakana += "。"
            elsif ar[1] == '読点'
              @katakana += "、"
            elsif ar[1] == 'Number' || ar[0] == '-' || ar[1] == '括弧'
              @katakana += ar[0]
            elsif ar[1] == '空白'
              @katakana += "　"
            end
          elsif ar[1] == "Alphabet" ||ar[1] == "Number"
            @katakana += ar[0]
          else
            @katakana += ar[2]
          end
        end
        return @katakana
      end
    end

end
