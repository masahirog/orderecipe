class MaterialsController < AdminController
  protect_from_forgery :except => [:change_additives]
  def index
    if params[:store_id]
      @store_id = params[:store_id]
    else
      @store_id = 39
    end
    @search = Material.includes(:vendor).search(params).page(params[:page]).per(50)
    @materials_order_quantity = OrderMaterial.joins(:order).where(un_order_flag:false,orders:{fixed_flag:1}).where(delivery_date:(Date.today - 31)..Date.today,material_id:@search.ids).group(:material_id).sum(:order_quantity)
    respond_to do |format|
      format.html
      format.json{render :json => @search}
    end
  end

  def new
    @material = Material.new
    @stores_hash = {}
    Store.all.each do |store|
      @stores_hash[store.id]=store.name
      if store.id == 39
        @material.material_store_orderables.build(store_id:store.id,orderable_flag:true)
      else
        @material.material_store_orderables.build(store_id:store.id)
      end
    end
    @material.material_food_additives.build
    @material.measurement_flag=true
    @food_additive = FoodAdditive.new
  end

  def create
    @material = Material.create(material_params)
    if @material.save
     redirect_to @material, notice: "「#{@material.name}」を作成しました。続けて食材を作成する：<a href='/materials/new'>新規作成</a>".html_safe
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
    @stores_hash = Store.all.map{|store|[store.id,store.name]}.to_h
    all_store_ids = @stores_hash.keys
    new_store_ids = all_store_ids - store_ids
    new_store_ids.each do |store_id|
      @material.material_store_orderables.build(store_id:store_id)
    end

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
    @stores_hash = Store.all.map{|store|[store.id,store.name]}.to_h
    @material = Material.find(params[:id])
    if params[:material][:inventory_flag] == 'true'
      @class_name = ".inventory_tr_#{@material.id}"
    end
    respond_to do |format|
      if @material.update(material_params)
        format.html {
          if params["material"]["back_to"].blank?
            redirect_to material_path, notice: "「#{@material.name}」を更新しました。続けてメニューを作成する：<a href='/materials/new'>新規作成</a>".html_safe
          else
            redirect_to params["material"]["back_to"], notice: "「#{@material.name}」を更新しました：".html_safe
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
     redirect_to include_material_materials_path(id:material_id), notice: "食材を変更しました。"
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
    if params[:kubun].present?
      kubun = params[:kubun]
    else
      kubun = '0'
    end
    if kubun == "0"
      @kubun = "くるめし"
    else
      @kubun = "べじはん"
    end
    from = Date.new(@year.to_i,@month.to_i,1)
    to = from.end_of_month
    @product_hash = {}
    @material_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @vendor_hash = Vendor.all.map{|vendor|[vendor.id,vendor.company_name]}.to_h
    if kubun == '0'
      kurumesi_order_ids = KurumesiOrder.where(start_time:from..to,canceled_flag:false)
      KurumesiOrderDetail.where(kurumesi_order_id:kurumesi_order_ids).each do |kod|
        if @product_hash[kod.product_id]
          @product_hash[kod.product_id] += kod.number
        else
          @product_hash[kod.product_id] = kod.number
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
    else
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
    end
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "#{@year}_#{@month}_#{@kubun}.csv", type: :csv
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

  private
  def material_params
    params.require(:material).permit(:name, :order_name, :recipe_unit_quantity, :recipe_unit,:vendor_stock_flag,:image,:image_cache,:remove_image,:short_name,:storage_place,
     :recipe_unit_price, :cost_price, :category, :order_code, :order_unit, :memo, :unused_flag, :vendor_id,:order_unit_quantity,:delivery_deadline,:accounting_unit,:accounting_unit_quantity,:measurement_flag,
     {allergy:[]},material_store_orderables_attributes:[:id,:store_id,:material_id,:orderable_flag],material_food_additives_attributes:[:id,:material_id,:food_additive_id,:_destroy],
   material_cut_patterns_attributes:[:id,:material_id,:name])
  end
end
