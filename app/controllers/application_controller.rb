require "google_drive"

class ApplicationController < ActionController::Base
  # http_basic_authenticate_with :name => ENV['BASIC_AUTH_USERNAME'], :password => ENV['BASIC_AUTH_PASSWORD'] if Rails.env == "production"
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_action :authenticate_user!, if: :use_auth?
  protect_from_forgery with: :exception
  add_flash_types :success, :info, :warning, :danger
  before_action :user_check
  def user_check
    @today = Date.today
    if user_signed_in? && current_user.group_id.present?
      @stores = current_user.group.stores.where(store_type:0)
    end
  end
  def mealselect_save
    date = params[:date]
    updates_arr = []
    params[:mealselect_num].each do |data|
      daily_menu_detail = DailyMenuDetail.find(data[0])
      daily_menu_detail.mealselect_num = data[1]
      updates_arr << daily_menu_detail
    end
    DailyMenuDetail.import updates_arr, on_duplicate_key_update:[:mealselect_num]
    redirect_to list_path(date:date), :info => "個数を入力しました。"
  end

  def image_download
    product = Product.find(params[:id])
    data = open(product.image.url)
    send_data(data.read, type:product.image.file.content_type, filename: product.image.file.filename)

  end

  def after_sign_in_path_for(resource)
    if current_user.admin?
      root_url
    elsif current_user.id == 49
      shifts_path(group_id:current_user.group_id,store_type:0)
    elsif current_user.id == 69
      crew_stores_path
    elsif current_user.vendor_flag == true
      vendor_orders_path
    end
  end
  def render_500(e)
    ExceptionNotifier.notify_exception(e, :env => request.env, :data => {:message => "your error message"})
    render template: 'errors/error_500', status: 500
  end
  def list
    @allergies = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    if params[:date].present?
      @date = Date.parse(params[:date])
      if @date < Date.parse('2024-01-01')
        flash[:notice] = "2024年1月以降を選択してください"
        @date = @today
      end
    else
      @date = @today
    end
    @daily_menu = DailyMenu.find_by(start_time:@date)
    if params[:all_display_flag].present?
      daily_menu_details = @daily_menu.daily_menu_details.includes(product:[:menus])
    else
      daily_menu_details = @daily_menu.daily_menu_details.includes(product:[:menus]).where(mealselect_flag:true) 
    end
    product_categories = [1,2,3,5,7,8,11,19,20,21,22]
    @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @data = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @bento_seibun = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }

    daily_menu_details.each do |dmd|
      @hash[dmd.product.product_category_before_type_cast][dmd.product_id] = dmd
      allergy = Product.allergy_seiri(dmd.product)
      product = dmd.product
      @bento_seibun[product.id] = {calorie:0,protein:0,lipid:0,carbohydrate:0,dietary_fiber:0,salt:0}
      product.product_menus.each do |pm|
        tpm = TemporaryProductMenu.find_by(daily_menu_detail_id:dmd.id,product_menu_id:pm.id)
        if tpm.present?
          menu = tpm.menu
        else
          menu = pm.menu
        end
        if menu.category == "容器"
        else
          @bento_seibun[product.id][:calorie] += menu.calorie
          @bento_seibun[product.id][:protein] += menu.protein
          @bento_seibun[product.id][:lipid] += menu.lipid
          @bento_seibun[product.id][:carbohydrate] += menu.carbohydrate
          @bento_seibun[product.id][:dietary_fiber] += menu.dietary_fiber
          @bento_seibun[product.id][:salt] += menu.salt

          if @data[product.id].present?
            @data[product.id] += "、【#{menu.food_label_name}】#{menu.food_label_contents}"
          else
            @data[product.id] = "【#{menu.food_label_name}】#{menu.food_label_contents}"
          end
        end
      end
      if product.product_category == "お弁当"
        @daily_menu.daily_menu_details.includes(product:[:menus]).where(paper_menu_number:[2,3]).each do |dmd|
          fukusai_product = dmd.product
          allergy += Product.allergy_seiri(fukusai_product)
          fukusai_product.product_menus.each do |pm|
            menu = pm.menu
            if menu.category == "容器"
            else
              @bento_seibun[product.id][:calorie] += (menu.calorie * 0.3)
              @bento_seibun[product.id][:protein] += (menu.protein * 0.3)
              @bento_seibun[product.id][:lipid] += (menu.lipid * 0.3)
              @bento_seibun[product.id][:carbohydrate] += (menu.carbohydrate * 0.3)
              @bento_seibun[product.id][:dietary_fiber] += (menu.dietary_fiber * 0.3)
              @bento_seibun[product.id][:salt] += (menu.salt * 0.3)

              if @data[product.id].present?
                @data[product.id] += "、【#{menu.food_label_name}】#{menu.food_label_contents}"
              else
                @data[product.id] = "【#{menu.food_label_name}】#{menu.food_label_contents}"
              end
            end
          end
        end
      end
      fas = FoodAdditive.where(id:dmd.product.menus.map{|menu|menu.used_additives}.flatten.reject(&:blank?).uniq).map{|fa|fa.name}.join("、")
      if fas.present?
        @data[dmd.product_id] += "／#{fas}"
      else
      end
      allergy = allergy.uniq
      if allergy.present?
        @data[dmd.product_id] += "、(一部に#{allergy.join("、")}を含む)"
      else
      end
    end
    render :layout => false
  end

  def shibataya
    @employees = Staff.where(group_id:30,status:0).map{|staff|[staff.name,staff.staff_code]}
    if params[:date]
      @date = Date.parse(params[:date])
      if @date < @today || @today + 3 < @date
        @date = @today
      end
    else
      @date = @today
    end
    @daily_menu = DailyMenu.find_by(start_time:@date)
    product_ids = []
    @pre_order = PreOrder.new
    product_categories = [1,2,3,5,7,8,11,19,20,21,22]

    @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @data = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @bento_seibun = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }

    @daily_menu.daily_menu_details.includes(product:[:menus,product_menus:[:menu]]).each do |dmd|
      allergy = Product.allergy_seiri(dmd.product)
      product = dmd.product
      @bento_seibun[product.id] = {calorie:0,protein:0,lipid:0,carbohydrate:0,dietary_fiber:0,salt:0}
      product.product_menus.each do |pm|
        tpm = TemporaryProductMenu.find_by(daily_menu_detail_id:dmd.id,product_menu_id:pm.id)
        if tpm.present?
          menu = tpm.menu
        else
          menu = pm.menu
        end
        if menu.category == "容器"
        else
          @bento_seibun[product.id][:calorie] += menu.calorie
          @bento_seibun[product.id][:protein] += menu.protein
          @bento_seibun[product.id][:lipid] += menu.lipid
          @bento_seibun[product.id][:carbohydrate] += menu.carbohydrate
          @bento_seibun[product.id][:dietary_fiber] += menu.dietary_fiber
          @bento_seibun[product.id][:salt] += menu.salt
          if @data[product.id].present?
            @data[product.id] += "、【#{menu.food_label_name}】#{menu.food_label_contents}"
          else
            @data[product.id] = "【#{menu.food_label_name}】#{menu.food_label_contents}"
          end
        end
      end
      if product.product_category == "お弁当"
        @daily_menu.daily_menu_details.includes(product:[:menus]).where(paper_menu_number:[2,3]).each do |dmd|
          fukusai_product = dmd.product
          allergy += Product.allergy_seiri(fukusai_product)
          fukusai_product.product_menus.each do |pm|
            menu = pm.menu
            if menu.category == "容器"
            else
              @bento_seibun[product.id][:calorie] += (menu.calorie * 0.3)
              @bento_seibun[product.id][:protein] += (menu.protein * 0.3)
              @bento_seibun[product.id][:lipid] += (menu.lipid * 0.3)
              @bento_seibun[product.id][:carbohydrate] += (menu.carbohydrate * 0.3)
              @bento_seibun[product.id][:dietary_fiber] += (menu.dietary_fiber * 0.3)
              @bento_seibun[product.id][:salt] += (menu.salt * 0.3)

              if @data[product.id].present?
                @data[product.id] += "、【#{menu.food_label_name}】#{menu.food_label_contents}"
              else
                @data[product.id] = "【#{menu.food_label_name}】#{menu.food_label_contents}"
              end
            end
          end
        end
      end
      fas = FoodAdditive.where(id:dmd.product.menus.map{|menu|menu.used_additives}.flatten.reject(&:blank?).uniq).map{|fa|fa.name}.join("、")
      if fas.present?
        @data[dmd.product_id] += "／#{fas}"
      else
      end
      allergy = allergy.uniq
      if allergy.present?
        @data[dmd.product_id] += "、(一部に#{allergy.join("、")}を含む)"
      else
      end


      if product_categories.include?(dmd.product.product_category_before_type_cast)
        tax_including_sell_price = (dmd.sell_price * 1.08).floor
        @pre_order.pre_order_products.build(product_id:dmd.product_id,order_num:0,welfare_price:0,employee_discount:0,tax_including_sell_price:tax_including_sell_price)
      end
    end
    [14099,14714].each do |id|
      product = Product.find(id)
      tax_including_sell_price = (product.sell_price * 1.08).floor
      @pre_order.pre_order_products.build(product_id:id,order_num:0,welfare_price:0,employee_discount:0,tax_including_sell_price:tax_including_sell_price)
    end
    @stores = Store.where(id:[9,19,29,154,164])
    @times = []
    (11..20).each do |h|
      ["00","15","30","45"].each do |m|
        @times << "#{h}:#{m}"
      end
    end
    
    render :layout => 'shibataya'
  end
  def shibataya_howto
    render :layout => 'shibataya'
  end
  def shibataya_orders
    if params[:date]
      @date = Date.parse(params[:date])
    else
      @date = @today
    end
    @pre_orders = PreOrder.includes(:store,pre_order_products:[:product]).where(date:@date)
    render :layout => 'shibataya'
  end


  private

  def use_auth?
    unless controller_name == 'pre_orders' || action_name == 'shibataya'|| action_name == 'shibataya_orders' || action_name == 'shibataya_howto'|| action_name == 'list'|| action_name == 'image_download' || action_name == "mealselect_save"
      true
    end
  end      
  protected
    # def revert_link
    #   view_context.link_to('取消', revert_version_path(@material.versions.last), :method => :post)
    # end
    # def versions_link
    #   view_context.link_to('編集履歴', version_path(@material), :method => :get)
    # end
    # def revert_link_menu
    #   view_context.link_to('取消', revert_version_path(@menu.versions.last), :method => :post)
    # end

end
