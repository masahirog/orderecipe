class MaterialsController < ApplicationController
  protect_from_forgery :except => [:change_additives]
  def reflect_seibun
    @material = Material.find(params[:id]) 
    updates_arr = []
    menu_ids = []
    @material.menu_materials.each do |mm|
      if mm.gram_quantity > 0
        if mm.material.food_ingredient_id.present?
          food_ingredient = mm.material.food_ingredient
          mm.calorie = (food_ingredient.calorie * mm.gram_quantity).round(2)
          mm.protein = (food_ingredient.protein * mm.gram_quantity).round(2)
          mm.lipid = (food_ingredient.lipid * mm.gram_quantity).round(2)
          mm.carbohydrate = (food_ingredient.carbohydrate * mm.gram_quantity).round(2)
          mm.dietary_fiber = (food_ingredient.dietary_fiber * mm.gram_quantity).round(2)
          mm.salt = (food_ingredient.salt * mm.gram_quantity).round(2)
          updates_arr << mm
          menu_ids << mm.menu_id
        end
      end
    end
    MenuMaterial.import updates_arr, on_duplicate_key_update:[:calorie,:protein,:lipid,:carbohydrate,:dietary_fiber,:salt]
    menu_ids = menu_ids.uniq

    updates_arr = []
    Menu.where(id:menu_ids).each do |menu|
      menu.calorie = menu.menu_materials.sum(:calorie).round(2)
      menu.protein = menu.menu_materials.sum(:protein).round(2)
      menu.lipid = menu.menu_materials.sum(:lipid).round(2)
      menu.carbohydrate = menu.menu_materials.sum(:carbohydrate).round(2)
      menu.dietary_fiber = menu.menu_materials.sum(:dietary_fiber).round(2)
      menu.salt = menu.menu_materials.sum(:salt).round(2)
      updates_arr << menu
    end
    Menu.import updates_arr, on_duplicate_key_update:[:calorie,:protein,:lipid,:carbohydrate,:dietary_fiber,:salt]


    products = Product.joins(:menus).where(:menus =>{id:menu_ids})
    updates_arr = []
    products.each do |product|
      product.calorie = product.menus.sum(:calorie).round(2)
      product.protein = product.menus.sum(:protein).round(2)
      product.lipid = product.menus.sum(:lipid).round(2)
      product.carbohydrate = product.menus.sum(:carbohydrate).round(2)
      product.dietary_fiber = product.menus.sum(:dietary_fiber).round(2)
      product.salt = product.menus.sum(:salt).round(2)
      updates_arr << product
    end
    Product.import updates_arr, on_duplicate_key_update:[:calorie,:protein,:lipid,:carbohydrate,:dietary_fiber,:salt]
    redirect_to @material,info:'更新しました'
  end

  def scan
    @materials = []
    @material = nil
  end

  def get_material
    if params[:material_id]
      # janコード登録の呼び出し
      @material = Material.find(params[:material_id]) 
      @save_jancode_flag = true
    else
      # janでのストック登録の呼び出し
      @material = Material.find_by(jancode:params[:jancode])
      end_day_stock = 0
      if @material.present?
        @stock = Stock.where(date:(@today - 50)..@today,material_id:@material.id,store_id:39).order('date DESC').first
        if @stock.present?
        else
          @stock = Stock.new(store_id:39,date:@today,material_id:@material.id)
        end
      end
    end
    respond_to do |format|
      format.js
    end
  end
  def materials_used_amount
    date = @today - 365
    materials = Material.where(vendor_id:151)
    material_ids = materials.ids
    @materials_hash = materials.map{|material|[material.id,material]}.to_h
    @order_materials_quantity = OrderMaterial.where(material_id:material_ids,un_order_flag:false).where("delivery_date > ?",date).group(:material_id).sum(:order_quantity)
    @order_materials_quantity.each {|k,v| @order_materials_quantity[k] = v.to_i}
    year_ago_date = @today - 365
    product_counts = DailyMenuDetail.joins(:daily_menu).where(:daily_menus =>{start_time:year_ago_date..@today}).group(:product_id).count
    products = Product.where(id:product_counts.keys)
    @material_used_product_count = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    Material.where(id:@order_materials_quantity.keys).each do |material|
      menu_ids = material.menus.ids
      @material_used_product_count[material.id] = Product.where(brand_id:111).joins(:product_menus).where(:product_menus => {menu_id:menu_ids}).count
    end
  end
  def used_products
    @material = Material.find(params[:material_id])
    @menu_used = {}
    @material.menu_materials.each do |mm|
      if @menu_used[mm.menu_id].present?
        @menu_used[mm.menu_id] += mm.amount_used
      else
        @menu_used[mm.menu_id] = mm.amount_used
      end
    end
    menu_ids = @menu_used.keys
    product_ids = Product.where(brand_id:111).joins(:product_menus).where(:product_menus => {menu_id:menu_ids}).ids
    @daily_menu_detail_product_counts = DailyMenuDetail.joins(:daily_menu).where(:daily_menus => {start_time:(@today - 365)..@today}).where(product_id:product_ids).group(:product_id).count
    priority_row_product_ids = @daily_menu_detail_product_counts.sort_by { |_, v| v }.reverse.to_h.keys
    priority_products = Product.where(id:priority_row_product_ids)
    other_products = Product.where(id:(product_ids - priority_row_product_ids))
    product_ids = priority_row_product_ids + (product_ids - priority_row_product_ids)
    @material_used_products = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @products = Product.where(id:product_ids).order(['field(id, ?)', product_ids]).page(params[:page]).per(20)
    @products.each do |product|
      material_used = 0
      product.menus.each do |menu|
        material_used += @menu_used[menu.id].to_f
      end
      @material_used_products[product.id][:product] = product
      @material_used_products[product.id][:used_amount] = material_used
      @material_used_products[product.id][:sales_count] = @daily_menu_detail_product_counts[product.id]
    end
  end
  def index
    if params[:store_id]
      @store_id = params[:store_id]
    else
      @store_id = 39
    end
    @stores = current_user.group.stores
    @search = Material.includes(:vendor).search(params,current_user.group_id).page(params[:page]).per(50)
    @ids = @search.ids
    @materials_order_quantity = OrderMaterial.joins(:order).where(un_order_flag:false,orders:{fixed_flag:1}).where(delivery_date:(Date.today - 31)..Date.today,material_id:@ids).group(:material_id).sum(:order_quantity)
    respond_to do |format|
      format.html
      format.json{render :json => @search}
    end
  end

  def new
    @material = Material.new(group_id:current_user.group_id)
    @stores_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    if current_user.group_id == 9
      stores = Store.all
    else
      stores = @stores
    end
    stores.each do |store|
      @stores_hash[store.group_id][store.id]=store.name
      if current_user.group_id == 9
        @material.material_store_orderables.build(store_id:store.id)
      else
        @material.material_store_orderables.build(store_id:store.id,orderable_flag:true)
      end
    end
    @material.material_food_additives.build
    @material.measurement_flag=true
    @food_additive = FoodAdditive.new
    @materials = Material.where(vendor_id:559,unused_flag:false)
  end

  def create
    @stores_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    Store.where(group_id:current_user.group_id).each do |store|
      @stores_hash[store.group_id][store.id]=store.name
    end
    @material = Material.new(material_params)
    if @material.save
     redirect_to @material, success: "「#{@material.name}」を作成しました。続けて食材を作成する：<a href='/materials/new'>新規作成</a>".html_safe
    else
     render 'new'
    end
  end
  def show
    if params[:store_id]
      @store_id = params[:store_id]
    else
      @store_id = 39
    end
    @material = Material.includes(material_food_additives:[:food_additive]).find(params[:id])
  end

  def edit
    if params[:store_id]
      @store_id = params[:store_id]
    else
      @store_id = 39
    end
    @material = Material.find(params[:id])
    store_ids = @material.material_store_orderables.pluck(:store_id)
    @stores_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    if current_user.group_id == 9
      stores = Store.all
    else
      stores = @stores
    end
    stores.each do |store|
      @stores_hash[store.group_id][store.id]=store.name
      @material.material_store_orderables.build(store_id:store.id) unless store_ids.include?(store.id)
    end
    @materials = []

    if request.referer.nil?
    elsif request.referer.include?("products")
      @back_to = request.referer
    elsif request.referer.include?("menus")
      @back_to = request.referer
    end
    @material.material_food_additives.build if @material.material_food_additives.length == 0
    @food_additive = FoodAdditive.new
  end

  def update
    @material = Material.find(params[:id])
    if params[:material][:inventory_flag] == 'true'
      @class_name = ".inventory_tr_#{@material.id}"
    end
    @stores_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    Store.where(group_id:current_user.group_id).each do |store|
      @stores_hash[store.group_id][store.id]=store.name
    end
    @materials = []
    respond_to do |format|
      if @material.update(material_params)
        format.html {
          if params["material"]["back_to"].blank?
            redirect_to material_path, success: "「#{@material.name}」を更新しました。続けてメニューを作成する：<a href='/materials/new'>新規作成</a>".html_safe
          else
            redirect_to params["material"]["back_to"], success: "「#{@material.name}」を更新しました：".html_safe
          end
        }
        format.js
      else
        format.html { render :edit }
        format.js
      end
    end
  end

  def include_material
    @menu_materials = MenuMaterial.includes(:material,:menu).where(material_id: params[:id]).page(params[:page]).per(20)
    @materials = Material.all
  end
  def include_update
    update_mms = params[:post]
    update_mms.each do |mm|
      @mm = MenuMaterial.find(mm[:mm_id])
      @mm.update_attribute(:material_id, mm[:material_id])
    end
     material_id = params[:material_id]
     redirect_to include_material_materials_path(id:material_id), success: "食材を変更しました。"
  end
  def material_cut_patterns_once_update
    mm_arr = []
    material_cut_pattern = MaterialCutPattern.find(params[:material_cut_pattern_id])
    menu_materials_hash = material_cut_pattern.menu_materials.map{|mm|[mm.id,mm]}.to_h
    params[:post].each do |data|
      menu_material_id = data[:menu_material_id].to_i
      menu_material = menu_materials_hash[menu_material_id]
      menu_material.preparation = data[:preparation]
      if menu_material.material_cut_pattern_id.to_s == data[:material_cut_pattern_id]
      else
        menu_material.material_cut_pattern_id = data[:material_cut_pattern_id]
      end
      mm_arr << menu_material
    end
    MenuMaterial.import mm_arr, on_duplicate_key_update:[:preparation,:material_cut_pattern_id]
    redirect_to cut_patterns_materials_path(material_cut_pattern_id:material_cut_pattern.id), success: "食材を変更しました。"
  end


  def change_additives
    @ar = Material.change_additives(params[:data])
    respond_to do |format|
      format.html
      format.json{render :json => @ar}
    end
  end

  def monthly_used_amount
    if params[:year].present?
      @year = params[:year]
    else
      @year = Date.today.year
    end
    if params[:month].present?
      @month = params[:month]
    else
      @month = Date.today.month
    end
    from = Date.new(@year.to_i,@month.to_i,1)
    to = from.end_of_month
    @product_hash = {}
    @material_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @vendor_hash = Vendor.all.map{|vendor|[vendor.id,vendor.name]}.to_h

    daily_menu_ids = DailyMenu.where(start_time:from..to)
    DailyMenuDetail.where(daily_menu_id:daily_menu_ids).each do |dmd|
      if @product_hash[dmd.product_id]
        @product_hash[dmd.product_id] += dmd.manufacturing_number
      else
        @product_hash[dmd.product_id] = dmd.manufacturing_number
      end
    end
    menu_ids = ProductMenu.where(product_id:@product_hash.keys).map{|pm|pm.menu_id}.uniq
    material_ids = MenuMaterial.where(menu_id:menu_ids).map{|mm|mm.material_id}.uniq
    # material_ids = @material_hash.keys
    material_id_order_amount = OrderMaterial.joins(:order).where(:orders => {store_id:39,fixed_flag:true}).where(material_id:material_ids,delivery_date:from..to,un_order_flag:false).group(:material_id).sum(:order_quantity).to_h
    ProductMenu.includes([:menu]).where(product_id:@product_hash.keys).each do |pm|
      num = @product_hash[pm.product_id]
      pm.menu.menu_materials.includes([:material]).each do |mm|
        if @material_hash[mm.material_id].present?
          @material_hash[mm.material_id][:amount_used] += (mm.amount_used * num)
          @material_hash[mm.material_id][:amount_price] += (mm.amount_used * num) * mm.material.cost_price
        else
          @material_hash[mm.material_id][:material] = mm.material
          @material_hash[mm.material_id][:amount_used] = (mm.amount_used * num)
          @material_hash[mm.material_id][:amount_price] = (mm.amount_used * num) * mm.material.cost_price
          @material_hash[mm.material_id][:order_amount] = material_id_order_amount[mm.material_id].to_f
        end
      end
    end
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "#{@year}_#{@month}.csv", type: :csv
      end
    end
  end

  def used_check
    @month_total_used = 0
    @today = Date.today
    @month_ago = @today-30
    @material = Material.find(params[:id])
    material_id = @material.id
    used_product_ids = Product.joins(product_menus:[menu:[:menu_materials]]).where(:product_menus => {:menus => {:menu_materials => {material_id:material_id}}}).ids
    month_bentos = DailyMenuDetail.joins(:daily_menu,:product).where(:daily_menus => {start_time:@month_ago..@today},:products => {id:used_product_ids}).group('product_id').sum(:manufacturing_number)
    month_bentos.each do |product_num|
      product = Product.find(product_num[0])
      menu_ids = product.menus.ids
      used = MenuMaterial.where(menu_id:menu_ids,material_id:material_id).sum(:amount_used)
      @month_total_used += (used * product_num[1])
    end
  end

  def cut_patterns
    @material_cut_pattern = MaterialCutPattern.find(params[:material_cut_pattern_id])
    @material = @material_cut_pattern.material
    @menu_materials = MenuMaterial.where(material_cut_pattern_id:@material_cut_pattern.id)
    @material_cut_patterns = @material.material_cut_patterns
  end
  def all_cut_patterns
    @material_cut_patterns = MaterialCutPattern.all.joins(:material).order("materials.short_name asc")
  end
  private
  def material_params
    params.require(:material).permit(:name, :order_name,:roma_name, :recipe_unit_quantity, :recipe_unit,:vendor_stock_flag,:image,:image_cache,:remove_image,:short_name,:storage_place,:group_id,:target_material_id,
     :recipe_unit_price, :cost_price, :category, :order_code, :order_unit, :memo, :unused_flag, :vendor_id,:order_unit_quantity,:delivery_deadline,:accounting_unit,:jancode,
     :accounting_unit_quantity,:measurement_flag,:price_update_date,:food_ingredient_id,:recipe_unit_gram_quantity,:food_label_name,
     {allergy:[]},material_store_orderables_attributes:[:id,:store_id,:material_id,:orderable_flag],material_food_additives_attributes:[:id,:material_id,:food_additive_id,:_destroy],
   material_cut_patterns_attributes:[:id,:material_id,:name,:machine,:_destroy,:roma_name])
  end
end
