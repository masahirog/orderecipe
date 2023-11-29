class MaterialsController < ApplicationController
  protect_from_forgery :except => [:change_additives]
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
    @search = Material.includes(:vendor).search(params,@group_id).page(params[:page]).per(50)
    @ids = @search.ids
    @materials_order_quantity = OrderMaterial.joins(:order).where(un_order_flag:false,orders:{fixed_flag:1}).where(delivery_date:(Date.today - 31)..Date.today,material_id:@ids).group(:material_id).sum(:order_quantity)
    respond_to do |format|
      format.html
      format.json{render :json => @search}
    end
  end

  def new
    @material = Material.new
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
    kurumesi_order_ids = KurumesiOrder.where(start_time:from..to,canceled_flag:false)
    KurumesiOrderDetail.where(kurumesi_order_id:kurumesi_order_ids).each do |kod|
      if @product_hash[kod.product_id]
        @product_hash[kod.product_id] += kod.number
      else
        @product_hash[kod.product_id] = kod.number
      end
    end
    daily_menu_ids = DailyMenu.where(start_time:from..to)
    DailyMenuDetail.where(daily_menu_id:daily_menu_ids).each do |dmd|
      if @product_hash[dmd.product_id]
        @product_hash[dmd.product_id] += dmd.manufacturing_number
      else
        @product_hash[dmd.product_id] = dmd.manufacturing_number
      end
    end
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
    shogun_bentos = DailyMenuDetail.joins(:daily_menu,:product).where(:daily_menus => {start_time:@month_ago..@today},:products => {id:used_product_ids}).group('product_id').sum(:manufacturing_number)
    kurumesi_bentos = KurumesiOrderDetail.joins(:kurumesi_order,:product).where(:kurumesi_orders => {start_time:@month_ago..@today,canceled_flag:false},:products => {id:used_product_ids}).group('product_id').sum(:number)
    month_bentos = shogun_bentos.merge(kurumesi_bentos)
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
     :recipe_unit_price, :cost_price, :category, :order_code, :order_unit, :memo, :unused_flag, :vendor_id,:order_unit_quantity,:delivery_deadline,:accounting_unit,:accounting_unit_quantity,:measurement_flag,
     {allergy:[]},material_store_orderables_attributes:[:id,:store_id,:material_id,:orderable_flag],material_food_additives_attributes:[:id,:material_id,:food_additive_id,:_destroy],
   material_cut_patterns_attributes:[:id,:material_id,:name,:machine,:_destroy,:roma_name])
  end
end
