class OrdersController < ApplicationController
  def material_reload
    @material = Material.find(params[:material_id])
    date = params[:date]
    @prev_stock = Stock.where("date <= ?", date).where(material_id:params[:material_id]).order("date DESC").first
  end
  def material_info
    @material = Material.find(params[:id])
    respond_to do |format|
      format.html
      format.json
    end
  end

  def edit
    today = Date.today
    @stock_hash ={}
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
      @stocks = Stock.where(material_id:material[0],date:(today - 5)..(today + 10)).order('date ASC')
      @stock_hash[material[0]] = @stocks.map do |stock|
        if stock.used_amount == 0
          used_amount = "<td style='color:silver;'>0</td>"
        else
          used_amount = "<td style='color:red;'>- #{(stock.used_amount/stock.material.accounting_unit_quantity).ceil(1)}#{stock.material.accounting_unit}</td>"
        end
        if stock.delivery_amount == 0
          delivery_amount = "<td style='color:silver;'>0</td>"
        else
          delivery_amount = "<td style='color:blue;'>+ #{(stock.delivery_amount/stock.material.accounting_unit_quantity).floor(1)}#{stock.material.accounting_unit}</td>"
        end
        if stock.end_day_stock == 0
          end_day_stock = "<td style='color:silver;'>0</td>"
        else
          end_day_stock = "<td style=''>#{(stock.end_day_stock/stock.material.accounting_unit_quantity).floor(1)}#{stock.material.accounting_unit}</td>"
        end
        if stock.inventory_flag == true
          inventory = "<td><span class='label label-success'>棚卸し</span></td>"
        else
          inventory = "<td></td>"
        end
        if stock.date >= today
          ["<tr style='background-color:#ffebcd;'><td>#{stock.date.strftime("%Y/%-m/%-d (#{%w(日 月 火 水 木 金 土)[stock.date.wday]})")}</td>#{delivery_amount}#{used_amount}#{end_day_stock}#{inventory}</tr>"]
        else
          ["<tr><td>#{stock.date.strftime("%Y/%-m/%-d (#{%w(日 月 火 水 木 金 土)[stock.date.wday]})")}</td>#{delivery_amount}#{used_amount}#{end_day_stock}#{inventory}</tr>"]
        end
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
    @prev_stocks = {}
    @stock_hash = {}
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
    elsif params[:kurumesi_order_date]
      order_products = []
      kurumesi_orders = KurumesiOrder.where(start_time:params[:kurumesi_order_date],canceled_flag:false)
      bentos_num_h = kurumesi_orders.joins(:kurumesi_order_details).group('kurumesi_order_details.product_id').sum('kurumesi_order_details.number')
      bentos_num_h.each do |aa|
        hash = {}
        hash[:product_id] = aa[0]
        hash[:num] = aa[1]
        hash[:make_date] = params[:kurumesi_order_date]
        order_products << hash
      end
      sales_date = Date.parse(params[:kurumesi_order_date])
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
            hash = {}
            hash['make_num'] = po[:num]
            hash['product_id'] = [product.id]
            hash['menu_num'] = {menu.name => po[:num]}
            hash['material_id'] = menu_material.material_id
            hash['calculated_order_amount'] = (po[:num].to_f * menu_material.amount_used)
            hash["recipe_unit_quantity"] = menu_material.material.recipe_unit_quantity
            hash["order_unit_quantity"] = menu_material.material.order_unit_quantity
            hash["vendor_id"] = menu_material.material.vendor_id
            hash['recipe_unit'] = menu_material.material.recipe_unit
            hash['order_unit'] = menu_material.material.order_unit
            hash['delivery_deadline'] = menu_material.material.delivery_deadline
            if hash['vendor_id'] == 141 || hash['vendor_id'] == 11 || hash['vendor_id'] == 161
              hash['order_material_memo'] = "#{menu_material.material.order_unit_quantity} #{menu_material.material.order_unit}：#{menu_material.material.recipe_unit_quantity} #{menu_material.material.recipe_unit}"
            else
              hash['order_material_memo'] =''
            end
            @arr << hash
          end
        end
      end
    end
    @b_hash = Hash.new { |h,k| h[k] = {} }
    @arr.sort_by! { |a| a['vendor_id'] }.each do |info|
      if @b_hash[info['material_id']].present?
        if @b_hash[info['material_id']]['product_id'].include?(info['product_id'])
          if @b_hash[info['material_id']]['menu_num'][info["menu_num"].keys[0]].present?
            @b_hash[info['material_id']]['calculated_order_amount'] += info['calculated_order_amount']
            @b_hash[info['material_id']]['menu_num'][info["menu_num"].keys[0]] += info['menu_num'].values[0]
          else
            @b_hash[info['material_id']]['calculated_order_amount'] += info['calculated_order_amount']
            @b_hash[info['material_id']]['menu_num'][info["menu_num"].keys[0]] = info['menu_num'].values[0]
          end
        else
          if @b_hash[info['material_id']]['menu_num'][info["menu_num"].keys[0]].present?
            @b_hash[info['material_id']]['calculated_order_amount'] += info['calculated_order_amount']
            @b_hash[info['material_id']]['menu_num'][info["menu_num"].keys[0]] += info['menu_num'].values[0]
            @b_hash[info['material_id']]['product_id'] << info['product_id'][0]
          else
            @b_hash[info['material_id']]['calculated_order_amount'] += info['calculated_order_amount']
            @b_hash[info['material_id']]['menu_num'][info["menu_num"].keys[0]] = info['menu_num'].values[0]
            @b_hash[info['material_id']]['product_id'] << info['product_id'][0]
          end
        end
      else
        @b_hash[info['material_id']] = info
      end
    end
    @prev_stocks = {}
    @stock_hash = {}
    @b_hash.each do |key,value|
      recipe_unit = value['recipe_unit']
      order_unit = value['order_unit']
      a = []
      value['menu_num'].each{|menu_name, num|a << "#{menu_name}【#{num}食】"}
      menu_name = a.join(',')
      order_material_memo = value['order_material_memo']
      dead_line = value['delivery_deadline']
      delivery_date = dead_line.business_days.before(sales_date)
      prev_stock = Stock.where("date < ?", sales_date).where(material_id:key).order("date DESC").first
      @prev_stocks[key] = prev_stock
      calculated_quantity = value['calculated_order_amount'].round(1)
      if prev_stock.present?
        if prev_stock.end_day_stock < 0
          shortage_stock = (-1 * prev_stock.end_day_stock).round(1)
          if value['order_unit_quantity'].to_f < 1
            i = 1
          else
            i = 0
          end
          order_quantity = BigDecimal((shortage_stock / value['recipe_unit_quantity'].to_f * value['order_unit_quantity'].to_f).to_s).ceil(i)
        else
          un_order_flag = true
          order_quantity = 0
        end
      else
        order_quantity = BigDecimal((calculated_quantity / value['recipe_unit_quantity'].to_f * value['order_unit_quantity'].to_f).to_s).ceil
        un_order_flag = false
      end
      @order.order_materials.build(material_id:key,order_quantity:order_quantity,calculated_quantity:calculated_quantity,menu_name:menu_name,recipe_unit:recipe_unit,order_unit:order_unit,order_material_memo:order_material_memo,delivery_date:delivery_date,un_order_flag:un_order_flag)
      # 在庫が必要である日==前日
      date = sales_date - 1
      @stocks = Stock.includes(:material).where(material_id:key,date:(date - 10)..(date + 5)).order('date ASC')
      @stock_hash[key] = @stocks.map do |stock|
        if stock.used_amount == 0
          used_amount = "<td style='color:silver;'>0</td>"
        else
          used_amount = "<td style='color:red;'>- #{(stock.used_amount/stock.material.accounting_unit_quantity).ceil(1)}#{stock.material.accounting_unit}</td>"
        end
        if stock.delivery_amount == 0
          delivery_amount = "<td style='color:silver;'>0</td>"
        else
          delivery_amount = "<td style='color:blue;'>+ #{(stock.delivery_amount/stock.material.accounting_unit_quantity).floor(1)}#{stock.material.accounting_unit}</td>"
        end
        if stock.end_day_stock == 0
          end_day_stock = "<td style='color:silver;'>0</td>"
        else
          end_day_stock = "<td style=''>#{(stock.end_day_stock/stock.material.accounting_unit_quantity).floor(1)}#{stock.material.accounting_unit}</td>"
        end
        if stock.inventory_flag == true
          inventory = "<td><span class='label label-success'>棚卸し</span></td>"
        else
          inventory = "<td></td>"
        end
        if stock.date == date
          ["<tr style='background-color:#ffebcd;'><td>#{stock.date.strftime("%Y/%-m/%-d (#{%w(日 月 火 水 木 金 土)[stock.date.wday]})")}</td>#{delivery_amount}#{used_amount}#{end_day_stock}#{inventory}</tr>"]
        else
          ["<tr><td>#{stock.date.strftime("%Y/%-m/%-d (#{%w(日 月 火 水 木 金 土)[stock.date.wday]})")}</td>#{delivery_amount}#{used_amount}#{end_day_stock}#{inventory}</tr>"]
        end
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
    @prev_stocks = {}
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
      :menu_name, :order_id, :material_id,:order_material_memo,:delivery_date,:recipe_unit,:order_unit, :un_order_flag,:_destroy],
      order_products_attributes: [:id,:make_date, :serving_for, :order_id, :product_id, :_destroy])
  end
end
