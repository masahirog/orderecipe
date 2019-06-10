class OrdersController < ApplicationController
  def material_info
    @material = Material.find(params[:id])
    respond_to do |format|
      format.html
      format.json
    end
  end

  def edit
    @hash = {}
    @prev_stocks = {}
    @materials = Material.where(unused_flag:false)
    @search_code_materials = Material.where(unused_flag:false).where.not(order_code:"")
    @order = Order.includes(:products,:order_products,:order_materials,{materials: [:vendor]}).find(params[:id])
    @code_materials = Material.where(unused_flag:false).where.not(order_code:"")
    @vendors = @order.order_materials.map{|om|[om.material.vendor.company_name,om.material.vendor.id]}.uniq
    product_ids = @order.products.ids
    materials = Product.includes(:product_menus,[menus: [menu_materials: :material]]).where(id:product_ids).map{|product| product.menus.map{|pm| pm.menu_materials.map{|mm|[mm.material.id, product.name]}}}.flatten(2)
    if @order.order_products.present?
      make_date = @order.order_products[0].make_date
      @order.order_materials.each do |om|
        prev_stock = Stock.where("date <= ?", make_date).where(material_id:om.material_id).order("date DESC").first
        @prev_stocks[om.material_id] = prev_stock
      end
    end
    materials.each do |material|
      if @hash[material[0]].present?
        @hash.store(material[0],@hash[material[0]] + "、" + material[1])
      else
        @hash.store(material[0],material[1])
      end
    end
  end

  def index
    @materials = Material.all
    @daily_menus = DailyMenu.includes(daily_menu_details:[:product]).all
    @products = Product.all
    if params[:material_id]
      material_id = params[:material_id]
      @orders = Order.includes(order_products:[:product]).joins(:order_materials).where(:order_materials => {material_id:material_id,un_order_flag:false}).order("id DESC").page(params[:page]).per(30)
    else
      @orders = Order.includes(order_products:[:product]).order("id DESC").page(params[:page]).per(30)
    end
  end
  def update
    @materials = Material.where(unused_flag:false)
    @search_code_materials = Material.where(unused_flag:false).where.not(order_code:"")
    @order = Order.includes(:products,:order_products,:order_materials,{materials: [:vendor]}).find(params[:id])
    @code_materials = Material.where(unused_flag:false).where.not(order_code:"")
    @vendors = @order.order_materials.map{|om|[om.material.vendor.company_name,om.material.vendor.id]}.uniq
    @order = Order.find(params[:id])
    if @order.update(order_create_update)
      redirect_to order_path
    else
      render "edit"
    end
  end

  def new
    @arr = []
    @order = Order.new
    if params[:daily_menu_id]
      order_products = []
      daily_menu = DailyMenu.find(params[:daily_menu_id])
      daily_menu.daily_menu_details.each do |dmd|
        hash = {}
        hash[:product_id] = dmd.product_id
        hash[:num] = dmd.manufacturing_number
        hash[:make_date] = daily_menu.start_time
        order_products << hash
      end
      sales_date = DailyMenu.find(params[:daily_menu_id]).start_time
    elsif params[:masu_order_date]
      order_products = []
      masu_orders = MasuOrder.where(start_time:params[:masu_order_date],canceled_flag:false)
      bentos_num_h = masu_orders.joins(:masu_order_details).group('masu_order_details.product_id').sum('masu_order_details.number')
      bentos_num_h.each do |aa|
        hash = {}
        hash[:product_id] = aa[0]
        hash[:num] = aa[1]
        hash[:make_date] = params[:masu_order_date]
        order_products << hash
      end
      sales_date = Date.parse(params[:masu_order_date])
    else
      order_products = params[:order]
      sales_date = Date.today
    end
    order_products.each do |po|
      if po[:product_id].present?
        product = Product.includes(:product_menus,[menus: [menu_materials: :material]]).find(po[:product_id])
        if po[:make_date].present?
          @order.order_products.build(product_id:po[:product_id],serving_for:po[:num],make_date:po[:make_date])
        else
          @order.order_products.build(product_id:po[:product_id],serving_for:po[:num])
        end
        product.menus.each do |menu|
          menu.menu_materials.each do |menu_material|
            unless menu_material.material.vendor_id == 111 || menu_material.material.vendor_id == 171 || menu_material.material.vendor_id == 21
              hash = {}
              hash['material_id'] = menu_material.material_id
              hash['calculated_order_amount'] = (po[:num].to_f * menu_material.amount_used)
              hash["menu_name"] = menu.name
              hash["calculated_value"] = menu_material.material.calculated_value
              hash["order_unit_quantity"] = menu_material.material.order_unit_quantity
              hash["vendor_id"] = menu_material.material.vendor_id
              hash['calculated_unit'] = menu_material.material.calculated_unit
              hash['order_unit'] = menu_material.material.order_unit
              hash['delivery_deadline'] = menu_material.material.delivery_deadline
              hash['unit_amount'] = "#{menu_material.material.order_unit_quantity} #{menu_material.material.order_unit}：#{menu_material.material.calculated_value} #{menu_material.material.calculated_unit}"
              @arr << hash
            end
          end
        end
      end
    end
    @b_hash = Hash.new { |h,k| h[k] = {} }
    @arr.sort_by! { |a| a['vendor_id'] }.each do |info|
      if info['vendor_id'] == 121 || info['vendor_id'] == 151
        if @b_hash[info['material_id']].present?
          @b_hash[info['material_id']] << info
        else
          @b_hash[info['material_id']] = [info]
        end
      else
        if @b_hash[info['material_id']].present?
          @b_hash[info['material_id']][0]['calculated_order_amount'] += info['calculated_order_amount']

          @b_hash[info['material_id']][0]['menu_name'] += "、" + info['menu_name']
        else
          @b_hash[info['material_id']] = [info]
        end
      end
    end
    @prev_stocks = {}
    @b_hash.each do |key,value|
      value.each do |hash|
        calculated_quantity = hash['calculated_order_amount'].round(1)
        if hash['order_unit_quantity'].to_f < 1
          order_quantity = BigDecimal((calculated_quantity / hash['calculated_value'].to_f * hash['order_unit_quantity'].to_f).to_s).ceil(1)
        else
          order_quantity = BigDecimal((calculated_quantity / hash['calculated_value'].to_f * hash['order_unit_quantity'].to_f).to_s).ceil
        end
        calculated_unit = hash['calculated_unit']
        order_unit = hash['order_unit']
        menu_name = hash['menu_name']
        unit_amount = hash['unit_amount']
        dead_line = hash['delivery_deadline']
        delivery_date = dead_line.business_days.before(sales_date)
        if hash['vendor_id'] == 141 || hash['vendor_id'] == 11 || hash['vendor_id'] == 161
          @order.order_materials.build(material_id:key,order_quantity:order_quantity,calculated_quantity:calculated_quantity,menu_name:menu_name,calculated_unit:calculated_unit,order_unit:order_unit,order_material_memo:unit_amount,delivery_date:delivery_date)
        else
          @order.order_materials.build(material_id:key,order_quantity:order_quantity,calculated_quantity:calculated_quantity,menu_name:menu_name,calculated_unit:calculated_unit,order_unit:order_unit,delivery_date:delivery_date)
        end
        prev_stock = Stock.where("date < ?", sales_date).where(material_id:key).order("date DESC").first
        @prev_stocks[key] = prev_stock
      end
    end
    @materials = Material.where(unused_flag:false)
    @vendors = @order.order_materials.map{|om|[om.material.vendor.company_name,om.material.vendor.id]}.uniq
  end

  def create
    @order = Order.create(order_create_update)
    @code_materials = Material.where(unused_flag:false).where.not(order_code:"")
    @materials = Material.where(unused_flag:false)
    @vendors = @order.order_materials.map{|om|[om.material.vendor.company_name,om.material.vendor.id]}.uniq
    if @order.save
      redirect_to "/orders/#{@order.id}"
    else
      render 'new'
    end
  end

  def show
    @order = Order.includes(:order_materials,[materials: :vendor],order_products:[:product]).find(params[:id])
    @vendors = Vendor.vendor_index(params)
  end

  def order_print
    @order = Order.find(params[:id])
    if params[:vendor][:id].present?
      @vendor = Vendor.find(params[:vendor][:id])
      @materials_this_vendor = Material.get_material_this_vendor(params)
      respond_to do |format|
       format.html
       format.pdf do
         pdf = OrderPdf.new(@materials_this_vendor,@vendor)
         pdf.font "vendor/assets/fonts/ipaexm.ttf"
         send_data pdf.render,
           filename:    "#{@order.id}_#{@vendor.company_name}.pdf",
           type:        "application/pdf",
           disposition: "inline"
         end
       end
     else
       redirect_to order_path(@order), alert: "企業を選択してください。"
     end
  end

  def print_all
    order = Order.includes(order_materials: [material: :vendor]).find(params[:id])
    respond_to do |format|
     format.html
     format.pdf do
       pdf = OrderPrintAll.new(order)
       send_data pdf.render,
         filename:    "#{order.id}.pdf",
         type:        "application/pdf",
         disposition: "inline"
     end
   end
  end

  def products_pdfs
    order = Order.includes({products: {menus: :menu_materials, menus: :materials}}).find(params[:order_id])
    respond_to do |format|
      format.html
      format.pdf do
        pdf = ProductPdfAll.new(order.id,'orders')
        send_data pdf.render,
        filename:    "#{order.id}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end
  def products_pdfs_roma
    order = Order.includes({products: {menus: :menu_materials, menus: :materials}}).find(params[:order_id])
    respond_to do |format|
      format.html
      format.pdf do
        pdf = ProductPdfAllRoma.new(order.id,'orders')
        send_data pdf.render,
        filename:    "#{order.id}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end


  def get_management_id
    @product = Product.find_by(management_id: params[:management_id])
    respond_to do |format|
      format.html
      format.json{render :json => @product}
    end
  end

  def check_management_id
    @product = Product.find(params[:id])
    respond_to do |format|
      format.html
      format.json{render :json => @product}
    end
  end

  def preparation_all
    @order = Order.includes({products: {menus: :menu_materials, menus: :materials}}).find(params[:order_id])
    respond_to do |format|
      format.html
      format.pdf do
        pdf = PreparationPdf.new(@order,'orders')
        send_data pdf.render,
        filename:    "preparation_all.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end


  def monthly
    @arr = []
    date = Date.new(params[:year].to_i,params[:month].to_i,1)
    @daily_menus = DailyMenu.includes(daily_menu_details:[product:[product_menus:[menu:[menu_materials:[:material]]]]]).where(start_time: date.in_time_zone.all_month)
    @daily_menus.each do |dm|
      dm.daily_menu_details.each do |dmd|
        dmd.product.product_menus.each do |pm|
          pm.menu.menu_materials.each do |mm|
            hash = {}
            num = dmd.manufacturing_number
            amount_used = mm.amount_used.to_f * num
            hash['material_id'] = mm.material_id
            hash['amount_used'] = amount_used.to_f
            hash["unit_cost"] = mm.material.cost_price.to_f
            hash["cost_price"] = mm.material.cost_price * amount_used
            hash["vendor_id"] = mm.material.vendor_id
            @arr << hash
          end
        end
      end
    end
    @ar = @arr.group_by{ |i| i['material_id']}
      .map{ |k, v|
         v[1..-1].each {|x| v[0]['amount_used'] += x['amount_used']; v[0]['cost_price'] += x['cost_price']}
         v[0]
      }.group_by{ |i| i['vendor_id']}
    @vendor_sum = @ar.map{ |k, v|
        v[1..-1].each {|x| v[0]['cost_price'] += x['cost_price']}
        v[0]
     }
     @total_cost = 0
     @vendor_sum.map{|hash| @total_cost += hash["cost_price"]}
  end
  private
  def order_create_update
    params.require(:order).permit(:fixed_flag,order_materials_attributes: [:id, :order_quantity,:calculated_quantity,
      :menu_name, :order_id, :material_id,:order_material_memo,:delivery_date,:calculated_unit,:order_unit, :un_order_flag,:_destroy],
      order_products_attributes: [:id,:make_date, :serving_for, :order_id, :product_id, :_destroy])
  end
end
