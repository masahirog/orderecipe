class VendorsController < ApplicationController
  def index
    if params[:all_flag]
      @vendors = Vendor.where(group_id:current_user.group_id)
    else
      @vendors = Vendor.where(group_id:current_user.group_id,status:1)
    end
    if params[:monthly_price] == 'true'
      if params[:year] && params[:month]
        @monthly_useds = {}
        @monthly_orders = {}
        @year = params[:year].to_i
        @month = params[:month].to_i
        from = Date.new(@year,@month,1)
        to = Date.new(@year,@month,-1)
        OrderMaterial.joins(:order).includes(:material).where(un_order_flag:false,orders:{fixed_flag:1}).where(delivery_date:from..to).each do |om|
          if @monthly_orders[om.material.vendor_id].present?
            @monthly_orders[om.material.vendor_id] += om.order_quantity.to_f * om.material.cost_price
          else
            @monthly_orders[om.material.vendor_id] = om.order_quantity.to_f * om.material.cost_price
          end
        end
        # material_ids = vendor.materials.ids
        # used_product_ids = Product.joins(product_menus:[menu:[:menu_materials]]).where(:product_menus => {:menus => {:menu_materials => {material_id:material_ids}}}).ids
        bejihan_souzais = DailyMenuDetail.joins(:daily_menu,:product).where(:daily_menus => {start_time:from.in_time_zone.all_month}).group('product_id').sum(:manufacturing_number)
        monthly_make_products = bejihan_souzais
        monthly_make_products.each do |product_num|
          product = Product.find(product_num[0])
          product.product_menus.includes(menu:[menu_materials:[:material]]).each do |pm|
            menu = pm.menu
            menu.menu_materials.each do |mm|
              if @monthly_useds[mm.material.vendor_id].present?
                @monthly_useds[mm.material.vendor_id] += (mm.amount_used * product_num[1] * mm.material.cost_price)
              else
                @monthly_useds[mm.material.vendor_id] = (mm.amount_used * product_num[1] * mm.material.cost_price)
              end
            end
          end
        end
      end
    end
  end

  def new
    @vendor = Vendor.new(group_id:current_user.group_id)
  end
  def create
    @vendor = Vendor.create(vendor_params)
    if @vendor.save
      redirect_to vendors_path
    else
      render 'new'
    end
  end
  def show
    @vendor = Vendor.find(params[:id])
  end

  def edit
    @vendor = Vendor.find(params[:id])
  end
  def update
    @vendor = Vendor.find(params[:id])
    @vendor.update(vendor_params)
    if @vendor.save
      redirect_to vendors_path
    else
      render 'edit'
    end
  end

  def monthly_used_amount
    @material_hash = Hash.new { |h,k| h[k] = Hash.new { |h,k| h[k] = {} } }
    @vendor_hash = {}
    year = params[:year].to_i
    month = params[:month].to_i
    date = Date.new(year,month,1)
    # material_ids = vendor.materials.ids
    # used_product_ids = Product.joins(product_menus:[menu:[:menu_materials]]).where(:product_menus => {:menus => {:menu_materials => {material_id:material_ids}}}).ids
    bejihan_souzais = DailyMenuDetail.joins(:daily_menu,:product).where(:daily_menus => {start_time:date.in_time_zone.all_month}).group('product_id').sum(:manufacturing_number)
    monthly_make_products = bejihan_souzais
    monthly_make_products.each do |product_num|
      product = Product.find(product_num[0])
      product.product_menus.includes(:menu).each do |pm|
        menu = pm.menu
        vendor_menu_materials = menu.menu_materials.includes([:material]).joins(:material).where(:materials => {vendor_id:params[:vendor_id]})
        vendor_menu_materials.each do |mm|
          if @material_hash[mm.material_id].present?
            @material_hash[mm.material_id]['amount'] += (mm.amount_used * product_num[1])
            @material_hash[mm.material_id]['cost'] += (mm.amount_used * product_num[1] * mm.material.cost_price)
          else
            @material_hash[mm.material_id]['material_name'] = mm.material.name
            @material_hash[mm.material_id]['amount'] = (mm.amount_used * product_num[1])
            @material_hash[mm.material_id]['cost'] = (mm.amount_used * product_num[1] * mm.material.cost_price)
          end
          if @vendor_hash.present?
            @vendor_hash += (mm.amount_used * product_num[1] * mm.material.cost_price)
          else
            @vendor_hash = (mm.amount_used * product_num[1] * mm.material.cost_price)
          end
        end
      end
    end
  end

  private
  def vendor_params
    params.require(:vendor).permit(:company_name, :company_phone, :company_fax, :company_mail,:status,:delivery_date,
                                    :zip, :address, :staff_name, :staff_phone, :staff_mail, :memo,:group_id,:name,:delivery_able_wday)
  end
end
