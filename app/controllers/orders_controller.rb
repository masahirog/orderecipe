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

  def deliveried_list
    if params[:date]
      @date = params[:date]
    else
      @date = Date.today
    end
    @order_materials = OrderMaterial.includes(:order,material:[:vendor]).where(delivery_date:@date,un_order_flag:false).order("vendors.id")
  end

  def edit
    today = Date.today
    vendor_name = {}
    all_materials = Material.includes(:vendor).where(unused_flag:false)
    @vendor_name =all_materials.map{|material|[material.id,material.vendor.company_name]}.to_h
    @stock_hash ={}
    @hash = {}
    @prev_stocks = {}
    @materials = []
    @search_code_materials = Material.where(unused_flag:false).where.not(order_code:"")
    @order = Order.includes(:products,:order_products,order_materials:[:material]).find(params[:id])
    @order.order_materials.each do |om|
      om.order_unit = om.material.order_unit
      om.recipe_unit = om.material.recipe_unit
      om.order_quantity_order_unit = ((om.order_quantity.to_f / om.material.recipe_unit_quantity) * om.material.order_unit_quantity).round(1)
    end
    @code_materials = Material.where(unused_flag:false).where.not(order_code:"")
    @vendors = @order.order_materials.includes(material:[:vendor]).map{|om|[om.material.vendor.company_name,om.material.vendor.id]}.uniq
    product_ids = @order.products.ids
    materials = Product.includes(:product_menus,[menus: [menu_materials: :material]]).where(id:product_ids).map{|product| product.menus.map{|pm| pm.menu_materials.map{|mm|[mm.material.id, product.name]}}}.flatten(2)
    if @order.order_products.present?
      make_date = @order.order_products[0].make_date
      stocks_hash = Stock.where("date < ?", make_date).order("date ASC").map{|stock|[stock.material_id,stock]}.to_h
      @order.order_materials.each do |om|
        @prev_stocks[om.material_id] = stocks_hash[om.material_id]
      end
    end
    stock_hash = {}
    @stocks = Stock.includes(:material).where(date:(today - 5)..(today + 10)).order('date ASC').map do |stock|
      if stock_hash[stock.material_id].present?
        stock_hash[stock.material_id] << stock
      else
        stock_hash[stock.material_id] = [stock]
      end
    end
    materials.each do |material|
      if @hash[material[0]].present?
        @hash.store(material[0],@hash[material[0]] + "、" + material[1])
      else
        @hash.store(material[0],material[1])
      end
      material_stock_hash = stock_hash[material[0]]
      if material_stock_hash.present?
        @stock_hash[material[0]] = material_stock_hash.map do |stock|
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
  end

  def index
    @materials = Material.all
    if params[:material_id]
      material_id = params[:material_id]
      @orders = Order.includes(:products,order_products:[:product]).joins(:order_materials).where(:order_materials => {material_id:material_id,un_order_flag:false}).order("id DESC").page(params[:page]).per(20)
    else
      @orders = Order.includes(:products,order_products:[:product]).order("id DESC").page(params[:page]).per(20)
    end
    @vendors_hash = Hash.new { |h,k| h[k] = {} }
    order_ids = @orders.map{|order|order.id}
    OrderMaterial.includes(material:[:vendor]).where(order_id:order_ids,un_order_flag:false).each do |om|
      if @vendors_hash[om.order_id][om.material.vendor_id].present?
        @vendors_hash[om.order_id][om.material.vendor_id][0] += 1
        if om.fax_sended_flag == true
          sended = true
        else
          sended = false
        end
        @vendors_hash[om.order_id][om.material.vendor_id][1] = sended
      else
        if om.fax_sended_flag == true
          sended = true
        else
          sended = false
        end
        @vendors_hash[om.order_id][om.material.vendor_id] = [1,sended,om.material.vendor.company_name]
      end
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
    if @order.update(order_create_update)
      redirect_to order_path
    else
      render "edit"
    end
  end


  def new
    @product_hash = {}
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
      make_date = DailyMenu.find(params[:daily_menu_id]).start_time
    elsif params[:kurumesi_order_date]
      order_products = []
      date = params[:kurumesi_order_date]
      # kurumesi_orders = KurumesiOrder.where(start_time:params[:kurumesi_order_date],canceled_flag:false)
      # bentos_num_h = kurumesi_orders.joins(:kurumesi_order_details).group('kurumesi_order_details.product_id').sum('kurumesi_order_details.number')
      params[:products].each do |id_num|
        hash = {}
        hash[:product_id] = id_num[1][:id].to_i
        hash[:num] = id_num[1][:num]
        hash[:make_date] = date
        order_products << hash
      end
      make_date = Date.parse(date)
    else
      # 折兼の発注機能
      order_products = []
      make_date = Date.today
      if params[:vendor_id].present?
        materials = Material.where(vendor_id:params[:vendor_id],unused_flag:0)
        materials.each do |material|
          hash = {}
          hash['material'] = material
          hash['make_num'] = 0
          hash['product_id'] = ''
          hash['menu_num'] = {'なし' => 0}
          hash['material_id'] = material.id
          hash['calculated_order_amount'] = 0
          hash["recipe_unit_quantity"] = material.recipe_unit_quantity
          hash["order_unit_quantity"] = material.order_unit_quantity
          hash["vendor_id"] = material.vendor_id
          hash["vendor_name"] = material.vendor.company_name
          hash['recipe_unit'] = material.recipe_unit
          hash['order_unit'] = material.order_unit
          hash['delivery_deadline'] = material.delivery_deadline
          hash['order_material_memo'] =''
          @arr << hash
        end
      end
    end
    product_ids = order_products.map{|op|op[:product_id]}
    product_hash = Product.includes(:product_menus,[menus: [menu_materials: [material:[:vendor]]]]).where(id:product_ids).map{|product|[product.id,product]}.to_h
    order_products.each do |po|
      if po[:product_id].present? && po[:num].to_i > 0
        product = product_hash[po[:product_id]]
        @product_hash[po[:product_id]] = product.name
        if po[:make_date].present?
          @order.order_products.build(product_id:po[:product_id],serving_for:po[:num],make_date:po[:make_date])
        else
          @order.order_products.build(product_id:po[:product_id],serving_for:po[:num])
        end
        product.menus.each do |menu|
          menu.menu_materials.each do |menu_material|
            hash = {}
            hash['material'] = menu_material.material
            hash['make_num'] = po[:num]
            hash['product_id'] = [product.id]
            hash['menu_num'] = {menu.name => po[:num].to_i}
            hash['material_id'] = menu_material.material_id
            hash['calculated_order_amount'] = (po[:num].to_f * menu_material.amount_used)
            hash["recipe_unit_quantity"] = menu_material.material.recipe_unit_quantity
            hash["order_unit_quantity"] = menu_material.material.order_unit_quantity
            hash["vendor_id"] = menu_material.material.vendor_id
            hash["vendor_name"] = menu_material.material.vendor.company_name
            hash['recipe_unit'] = menu_material.material.recipe_unit
            hash['order_unit'] = menu_material.material.order_unit
            hash['delivery_deadline'] = menu_material.material.delivery_deadline
            hash['order_material_memo'] =''
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
            @b_hash[info['material_id']]['menu_num'][info["menu_num"].keys[0]] += info['menu_num'].values[0].to_i
          else
            @b_hash[info['material_id']]['calculated_order_amount'] += info['calculated_order_amount']
            @b_hash[info['material_id']]['menu_num'][info["menu_num"].keys[0]] = info['menu_num'].values[0].to_i
          end
        else
          if @b_hash[info['material_id']]['menu_num'][info["menu_num"].keys[0]].present?
            @b_hash[info['material_id']]['calculated_order_amount'] += info['calculated_order_amount']
            @b_hash[info['material_id']]['menu_num'][info["menu_num"].keys[0]] += info['menu_num'].values[0].to_i
            @b_hash[info['material_id']]['product_id'] << info['product_id'][0]
          else
            @b_hash[info['material_id']]['calculated_order_amount'] += info['calculated_order_amount']
            @b_hash[info['material_id']]['menu_num'][info["menu_num"].keys[0]] = info['menu_num'].values[0].to_i
            @b_hash[info['material_id']]['product_id'] << info['product_id'][0]
          end
        end
      else
        @b_hash[info['material_id']] = info
      end
    end

    @prev_stocks = {}
    @stock_hash = {}
    stocks_hash = {}
    stocks_hash = Stock.where("date < ?", make_date).order("date ASC").map{|stock|[stock.material_id,stock]}.to_h
    date = make_date - 1
    stock_hash = {}
    Stock.includes(:material).where(material_id:@b_hash.keys,date:(date - 10)..(date + 10)).order('date ASC').map do |stock|
      if stock_hash[stock.material_id].present? && stock_hash[stock.material_id].length < 11
        stock_hash[stock.material_id] << stock
      else
        stock_hash[stock.material_id] = [stock]
      end
    end
    @b_hash.each do |key,value|
      material = value['material']
      recipe_unit = value['recipe_unit']
      order_unit = value['order_unit']
      a = []
      value['menu_num'].each{|menu_name, num|a << "#{menu_name}【#{num}食】"}
      menu_name = a.join(',')
      order_material_memo = value['order_material_memo']
      dead_line = value['delivery_deadline']
      delivery_date = dead_line.business_days.before(make_date)
      # prev_stock = Stock.where("date < ?", make_date).where(material_id:key).order("date DESC").first
      # @prev_stocks[key] = prev_stock
      @prev_stocks[key] = stocks_hash[key]
      calculated_quantity = value['calculated_order_amount'].round(1)
      if value['order_unit_quantity'].to_f < 1
        i = 1
      else
        i = 0
      end
      # 直近の在庫から発注量を計算
      if stocks_hash[key].present? && material.stock_management_flag == true
        if stocks_hash[key].end_day_stock < 0
          shortage_stock = (-1 * stocks_hash[key].end_day_stock).round(1)
          order_quantity_order_unit = ((shortage_stock / value['recipe_unit_quantity'].to_f) * value['order_unit_quantity'].to_f).ceil(i)
        else
          un_order_flag = true
          order_quantity_order_unit = 0
        end
      else
        order_quantity_order_unit = (calculated_quantity / value['recipe_unit_quantity'].to_f * value['order_unit_quantity'].to_f).ceil(i)
      end

      @order.order_materials.build(material_id:key,recipe_unit:recipe_unit,order_unit:order_unit,order_quantity_order_unit:order_quantity_order_unit,calculated_quantity:calculated_quantity,menu_name:menu_name,order_material_memo:order_material_memo,delivery_date:delivery_date,un_order_flag:un_order_flag)

      if stock_hash[key].present?
        material_stock_hash = stock_hash[key].map{|data|[data.date,data]}.to_h
        @thead = ["<th>日付</th>"]
        @tr0 = ["<td>始在庫</td>"]
        @tr1 = ["<td>納品</td>"]
        @tr2 = ["<td>使用</td>"]
        @tr3 = ["<td>終在庫</td>"]
        @tr4 = ["<td>棚卸</td>"]

        (date-10..date+10).each do |day|
          if material_stock_hash[day].present?
            stock = material_stock_hash[day]
            if stock.used_amount == 0
              used_amount = "<td style='color:silver;'>0</td>"
            else
              used_amount = "<td style='color:darkorange;'>- #{(stock.used_amount/stock.material.accounting_unit_quantity).ceil(1)}#{stock.material.accounting_unit}</td>"
            end
            if stock.delivery_amount == 0
              delivery_amount = "<td style='color:silver;'>0</td>"
            else
              delivery_amount = "<td style='color:blue;'>+ #{(stock.delivery_amount/stock.material.accounting_unit_quantity).floor(1)}#{stock.material.accounting_unit}</td>"
            end
            if stock.end_day_stock == 0
              end_day_stock = "<td style='color:silver;'>0</td>"
            elsif stock.end_day_stock < 0
              end_day_stock = "<td style='color:red;'>#{(stock.end_day_stock/stock.material.accounting_unit_quantity).floor(1)}#{stock.material.accounting_unit}</td>"
            else
              end_day_stock = "<td style=''>#{(stock.end_day_stock/stock.material.accounting_unit_quantity).floor(1)}#{stock.material.accounting_unit}</td>"
            end
            if stock.start_day_stock == 0
              start_day_stock = "<td style='color:silver;'>0</td>"
            else
              start_day_stock = "<td style=''>#{(stock.start_day_stock/stock.material.accounting_unit_quantity).floor(1)}#{stock.material.accounting_unit}</td>"
            end

            if stock.inventory_flag == true
              inventory = "<td><span class='label label-success'>棚卸し</span></td>"
            else
              inventory = "<td></td>"
            end
            if stock.date == date
              @thead << "<th style='text-align:center;background-color:#ffebcd;'>#{day.strftime("%-m/%-d(#{%w(日 月 火 水 木 金 土)[stock.date.wday]})")}</th>"
              @tr0 << start_day_stock
              @tr1 << delivery_amount
              @tr2 << used_amount
              @tr3 << end_day_stock
              @tr4 << inventory
            else
              @thead << "<th style='text-align:center;'>#{day.strftime("%-m/%-d(#{%w(日 月 火 水 木 金 土)[day.wday]})")}</th>"
              @tr0 << start_day_stock
              @tr1 << delivery_amount
              @tr2 << used_amount
              @tr3 << end_day_stock
              @tr4 << inventory
            end
          else
            @thead << "<th style='text-align:center;'>#{day.strftime("%-m/%-d(#{%w(日 月 火 水 木 金 土)[day.wday]})")}</th>"
            @tr0 << "<td></td>"
            @tr1 << "<td></td>"
            @tr2 << "<td></td>"
            @tr3 << "<td></td>"
            @tr4 << "<td></td>"
          end
        end
        @stock_hash[key] = ["<thead><tr>#{@thead.join('')}</tr></thead><tbody><tr>#{@tr0.join('')}</tr><tr>#{@tr1.join('')}</tr><tr>#{@tr2.join('')}</tr><tr>#{@tr3.join('')}</tr><tr>#{@tr4.join('')}</tr><tbody>"]
      end
    end
    @materials = []
    @vendors = Vendor.all.map{|vendor|[vendor.company_name,vendor.id]}
  end

  def create
    @stock_hash = {}
    @order = Order.new(order_create_update)
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
    @order = Order.includes(order_products:[:product]).find(params[:id])
    @order_materials = OrderMaterial.includes(material:[:vendor]).where(order_id:@order.id,un_order_flag:false)
    @vendors = Vendor.vendor_index(params)
  end

  def order_print
    order_id = params[:id]
    @order = Order.find(order_id)
    if params[:vendor][:id].present?
      vendor_id = params[:vendor][:id]
      @vendor = Vendor.find(vendor_id)
      @materials_this_vendor = Material.get_material_this_vendor(order_id,vendor_id)
      respond_to do |format|
       format.html
       format.pdf do
         pdf = OrderPdf.new(@materials_this_vendor,@vendor,@order)

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

  def send_order_fax
    vendor_ids = params['vendor_id'].keys
    vendors = Vendor.where(id:vendor_ids)
    order = Order.find(params[:order_id])
    vendors.each do |vendor|
      NotificationMailer.send_order(order,vendor).deliver
    end
    redirect_to order, notice: "#{vendors.length} 件のFAXを送信しました。しばらくたったあとにFAXが届いているか確認してください。"
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
    params[:order][:order_materials_attributes].each do |om|
      material = Material.find(om[1]['material_id'])
      recipe_unit_quantity = material.recipe_unit_quantity
      order_unit_quantity = material.order_unit_quantity
      if om[1]['order_quantity_order_unit'].to_f > 0
        om[1]['order_quantity'] = ((om[1]['order_quantity_order_unit'].to_f * recipe_unit_quantity.to_f)/ order_unit_quantity.to_f).round(1)
      else
        om[1]['order_quantity'] = 0
      end
    end
    params.require(:order).permit(:fixed_flag,order_materials_attributes: [:id,:calculated_quantity,:order_quantity_order_unit,:order_quantity,
      :menu_name, :order_id, :material_id,:order_material_memo,:delivery_date, :un_order_flag,:_destroy],
      order_products_attributes: [:id,:make_date, :serving_for, :order_id, :product_id, :_destroy])
  end
end
