class OrdersController < AdminController

  def monthly_data
    if params[:start_date].present?
      date = params[:start_date].to_date
    elsif params[:start_time].present?
      date = params[:start_time].to_date
    else
      date = @today
    end
    store_id = params[:store_id]
    @store = Store.find(store_id)
    
    @order_materials = OrderMaterial.joins(:order).where(:orders => {store_id:store_id}).where(delivery_date:date.beginning_of_month..date.end_of_month).where(un_order_flag:false)
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "#{date}_#{store_id}_Ashohin.csv", type: :csv
      end
    end
  end
  def suriho

  end
  def bejihan_store_orders_list
    if params[:date]
      @date = Date.parse(params[:date])
    else
      @date = @today
    end
    if params[:store_id].present?
      store_ids = [params[:store_id]]
      @stores = Store.where(id:store_ids)
    else
      @stores = Store.all
      store_ids = @stores.ids
    end
    @order_materials = OrderMaterial.includes(order:[:store],material:[:vendor]).where(:materials => {vendor_id:[559]}).where(:orders => {store_id:store_ids,fixed_flag:true}).where(delivery_date:@date,un_order_flag:false).order("vendors.id")
    @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @order_materials.each do |om|
      if @hash[om.order.store_id][om.material_id].present?
        @hash[om.order.store_id][om.material_id][:order_quantity] += om.order_quantity.to_f
      else
        @hash[om.order.store_id][om.material_id][:order_quantity] = om.order_quantity.to_f
        @hash[om.order.store_id][om.material_id][:material] = om.material
      end
      @hash[om.order.store_id][om.material_id][:orders][om.order_id][:memo] = om.order_material_memo
      @hash[om.order.store_id][om.material_id][:orders][om.order_id][:order] = om.order
    end
    respond_to do |format|
      format.html
      format.pdf do
        pdf = BejihanStoreOrdersDeliveryList.new(@hash,@date)
        send_data pdf.render,
        filename:    "納品リスト.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end

  def material_reload
    @material = Material.find(params[:material_id])
    date = params[:date]
    store_id = params[:store_id]
    @prev_stock = Stock.where(store_id:store_id).where("date <= ?", date).where(material_id:params[:material_id]).order("date DESC").first
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
      @date = @today
    end
    store_id = params[:store_id]
    @store = Store.find(store_id)
    if params[:vendor_id].present?
      vendor_id = params[:vendor_id]
      @order_materials = OrderMaterial.includes(:order,material:[:vendor]).where(:orders => {fixed_flag:true,store_id:store_id}).where(delivery_date:@date,un_order_flag:false).where(:materials => {vendor_id:vendor_id})
    else
      @order_materials = OrderMaterial.includes(:order,material:[:vendor]).where(:orders => {fixed_flag:true,store_id:store_id}).where(delivery_date:@date,un_order_flag:false).order("vendors.id")
    end
    @hash = {}
    @order_materials.each do |om|
      if @hash[om.material_id].present?
        @hash[om.material_id][1] += om.order_quantity.to_f
      else
        @hash[om.material_id] = [om.material.recipe_unit_quantity,om.order_quantity.to_f,om.material.order_name,om.material.order_unit,om.order_material_memo,om.order_id,om.material.vendor.name,om.material.order_unit_quantity]
      end
    end
    respond_to do |format|
      format.html
      format.pdf do
        pdf = DeliveriedList.new(@hash)
        send_data pdf.render,
        filename:    "納品リスト.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end

  def edit
    gon.holidays = HolidayJapan.list_year(@today.year).map{|data|data[0].to_s.delete('-')}
    today = @today
    vendor_name = {}
    all_materials = Material.includes(:vendor).where(unused_flag:false)
    # @vendor_name =all_materials.map{|material|[material.id,material.vendor.name]}.to_h
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
    @vendors = @order.order_materials.includes(material:[:vendor]).map{|om|[om.material.vendor.name,om.material.vendor.id]}.uniq
    product_ids = @order.products.ids
    # materials = Product.includes(:product_menus,[menus: [menu_materials: :material]]).where(id:product_ids).map{|product| product.menus.map{|pm| pm.menu_materials.map{|mm|[mm.material.id, product.name]}}}.flatten(2)
    materials = @order.order_materials.map{|om|om.material}
    if @order.order_products.present?
      make_date = @order.order_products[0].make_date
      stocks_hash = Stock.where(store_id:@order.store_id).where("date < ?", make_date).order("date ASC").map{|stock|[stock.material_id,stock]}.to_h
      @order.order_materials.each do |om|
        @prev_stocks[om.material_id] = stocks_hash[om.material_id]
      end
    end
    stock_hash = {}
    @stocks = Stock.includes(:material).where(store_id:@order.store_id).where(date:(today - 10)..(today + 10)).order('date ASC').map do |stock|
      if stock_hash[stock.material_id].present?
        stock_hash[stock.material_id] << stock
      else
        stock_hash[stock.material_id] = [stock]
      end
    end
    materials.each do |material|
      if stock_hash[material.id].present?
        material_stock_hash = stock_hash[material.id].map{|data|[data.date,data]}.to_h
      else
        material_stock_hash ={}
      end
      @thead = ["<th>日付</th>"]
      @tr0 = ["<td>始在庫</td>"]
      @tr1 = ["<td>納品</td>"]
      @tr2 = ["<td>使用</td>"]
      @tr3 = ["<td>終在庫</td>"]
      @tr4 = ["<td>棚卸</td>"]

      (today-10..today+10).each do |day|
        if day.wday == 0 || HolidayJapan.name(day).present?
          color = "color:red;"
        elsif day.wday == 6
          color = "color:blue;"
        else
          color = ""
        end
        if material_stock_hash[day].present?
          stock = material_stock_hash[day]
          zero = "<td style='color:silver;'>0</td>"
          if stock.used_amount == 0
            used_amount = zero
          else
            used_amount = "<td style='color:darkorange;'>- #{(stock.used_amount/stock.material.accounting_unit_quantity).ceil(1)}#{stock.material.accounting_unit}</td>"
          end
          if stock.delivery_amount == 0
            delivery_amount = zero
          else
            delivery_amount = "<td style='color:blue;'>+ #{(stock.delivery_amount/stock.material.accounting_unit_quantity).floor(1)}#{stock.material.accounting_unit}</td>"
          end
          if stock.end_day_stock == 0
            end_day_stock = zero
          elsif stock.end_day_stock < 0
            end_day_stock = "<td style='color:red;'>#{(stock.end_day_stock/stock.material.accounting_unit_quantity).floor(1)}#{stock.material.accounting_unit}</td>"
          else
            end_day_stock = "<td style=''>#{(stock.end_day_stock/stock.material.accounting_unit_quantity).floor(1)}#{stock.material.accounting_unit}</td>"
          end
          if stock.start_day_stock == 0
            start_day_stock = zero
          else
            start_day_stock = "<td style=''>#{(stock.start_day_stock/stock.material.accounting_unit_quantity).floor(1)}#{stock.material.accounting_unit}</td>"
          end

          if stock.inventory_flag == true
            inventory = "<td><span class='label label-success'>棚卸し</span></td>"
          else
            inventory = "<td></td>"
          end
          if stock.date == today
            bc = "background-color:#ffebcd;"
          else
            bc = ""
          end
          @thead << "<th style='text-align:center;#{bc}#{color}'>#{day.strftime("%-m/%-d(#{%w(日 月 火 水 木 金 土)[day.wday]})")}</th>"
          @tr0 << start_day_stock
          @tr1 << delivery_amount
          @tr2 << used_amount
          @tr3 << end_day_stock
          @tr4 << inventory
        else
          @thead << "<th style='text-align:center;background-color:white;#{color}'>#{day.strftime("%-m/%-d(#{%w(日 月 火 水 木 金 土)[day.wday]})")}</th>"
          @tr0 << "<td></td>"
          @tr1 << "<td></td>"
          @tr2 << "<td></td>"
          @tr3 << "<td></td>"
          @tr4 << "<td></td>"
        end
      end
      @stock_hash[material.id] = ["<thead><tr>#{@thead.join('')}</tr></thead><tbody><tr>#{@tr0.join('')}</tr><tr>#{@tr1.join('')}</tr><tr>#{@tr2.join('')}</tr><tr>#{@tr3.join('')}</tr><tr>#{@tr4.join('')}</tr><tbody>"]


    end
  end

  def index
    @today_wday = @today.wday
    @wdays = [['月曜日',1],['火曜日',2],['水曜日',3],['木曜日',4],['金曜日',5],['土曜日',6],['日曜日',7]]
    @materials = Material.all
    if params[:material_id]
      material_id = params[:material_id]
      @orders = Order.where(store_id:params[:store_id]).includes(:order_products).joins(:order_materials).where(:order_materials => {material_id:material_id,un_order_flag:false}).order("id DESC").page(params[:page]).per(20)
    else
      @orders = Order.where(store_id:params[:store_id]).includes(:order_products).order("id DESC").page(params[:page]).per(20)
    end
    @store = Store.find(params[:store_id])
    @vendors_hash = Hash.new { |h,k| h[k] = {} }
    order_ids = @orders.map{|order|order.id}
    OrderMaterial.includes(material:[:vendor]).where(order_id:order_ids,un_order_flag:false).each do |om|
      if @vendors_hash[om.order_id][om.material.vendor_id].present?
        @vendors_hash[om.order_id][om.material.vendor_id][0] += 1
        @vendors_hash[om.order_id][om.material.vendor_id][1] = om.status
      else
        @vendors_hash[om.order_id][om.material.vendor_id] = [1,om.status,om.material.vendor.name]
      end
    end
    if params[:start_date].present?
      @date = params[:start_date]
    else
      @date = @today
    end
    daily_menus = DailyMenu.where(start_time:@date.in_time_zone.all_month)
    @date_daily_menu_count= {}
    @date_daily_menu = {}
    daily_menus.each do |dm|
      @date_daily_menu_count[dm.start_time] = dm.daily_menu_details.sum(:manufacturing_number)
      @date_daily_menu[dm.start_time] = dm
    end

  end
  def update
    @prev_stocks = {}
    @stock_hash = {}
    @materials = Material.where(unused_flag:false)
    @search_code_materials = Material.where(unused_flag:false).where.not(order_code:"")
    @order = Order.includes(:products,:order_products,:order_materials,{materials: [:vendor]}).find(params[:id])
    @code_materials = Material.where(unused_flag:false).where.not(order_code:"")
    @vendors = @order.order_materials.map{|om|[om.material.vendor.name,om.material.vendor.id]}.uniq
    if @order.update(order_create_update)
      redirect_to order_path
    else
      render "edit"
    end
  end


  def new
    @temporary_menu_materials = {}
    gon.holidays = HolidayJapan.list_year(@today.year).map{|data|data[0].to_s.delete('-')}
    orderable_material_ids = MaterialStoreOrderable.where(store_id:params[:store_id],orderable_flag:true).map{|mso|mso.material_id}
    material_ids = []
    @product_hash = {}
    @arr = []
    @order = Order.new(store_id:params[:store_id])
    if params[:daily_menu_start_time]
      order_products = []
      date = params[:daily_menu_start_time]
      params[:products].each do |id_num|
        hash = {}
        hash[:product_id] = id_num[1][:id].to_i
        hash[:num] = id_num[1][:num]
        hash[:make_date] = date
        order_products << hash
      end
      make_date = Date.parse(date)
      @order.memo = "#{make_date.strftime("%-m/%-d(#{%w(日 月 火 水 木 金 土)[make_date.wday]})")} べじ 製造分"
    elsif params[:bihin_flag] == 'true'
      order_products = []
      make_date = (@today+2)
      materials = Material.includes([:vendor]).joins(:material_store_orderables).where(category:5,unused_flag:false).where(:material_store_orderables => {store_id:params[:store_id],orderable_flag:true}).order(short_name:'asc')
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
        hash["vendor_name"] = material.vendor.name.truncate(10)
        hash['recipe_unit'] = material.recipe_unit
        hash['order_unit'] = material.order_unit
        hash['delivery_deadline'] = material.delivery_deadline
        hash['order_material_memo'] =''
        hash["vendor_info"] = material.vendor.delivery_date
        hash["vendor_delivery_able_wday"] = material.vendor.delivery_able_wday
        @arr << hash
      end
    elsif params[:wday_new_order] == 'true'
      order_products = []
      make_date = (@today+2)
      @hash = {"1"=>'mon',"2"=>'tue',"3"=>'wed',"4"=>'thu',"5"=>'fri',"6"=>'sat',"7"=>'sun'}
      wday_nihongo_hash = {"1"=>'月曜日',"2"=>'火曜日',"3"=>'水曜日',"4"=>'木曜日',"5"=>'金曜日',"6"=>'土曜日',"7"=>'日曜日'}
      @youbi = wday_nihongo_hash[params[:wday]]
      @material_store_orderables = MaterialStoreOrderable.includes(material:[:vendor]).where(@hash[params[:wday]]=>'true',store_id:params[:store_id],orderable_flag:true)
      @material_store_orderables.each do |mso|
        hash = {}
        material = mso.material
        hash['material'] = material
        hash['make_num'] = 0
        hash['product_id'] = ''
        hash['menu_num'] = {'なし' => 0}
        hash['material_id'] = mso.material_id
        hash['calculated_order_amount'] = 0
        hash["recipe_unit_quantity"] = material.recipe_unit_quantity
        hash["order_unit_quantity"] = material.order_unit_quantity
        hash["vendor_id"] = material.vendor_id
        hash["vendor_name"] = material.vendor.name.truncate(10)
        hash['recipe_unit'] = material.recipe_unit
        hash['order_unit'] = material.order_unit
        hash['delivery_deadline'] = material.delivery_deadline
        hash['order_material_memo'] =''
        hash["vendor_info"] = material.vendor.delivery_date
        hash["vendor_delivery_able_wday"] = material.vendor.delivery_able_wday
        hash["order_criterion"] = mso.order_criterion
        @arr << hash
      end
    elsif params[:store_orderable_all_flag] == 'true'
      order_products = []
      make_date = (@today+2)
      @material_store_orderables = MaterialStoreOrderable.includes(material:[:vendor]).where(store_id:params[:store_id],orderable_flag:true)
      @material_store_orderables.each do |mso|
        hash = {}
        material = mso.material
        hash['material'] = material
        hash['make_num'] = 0
        hash['product_id'] = ''
        hash['menu_num'] = {'なし' => 0}
        hash['material_id'] = mso.material_id
        hash['calculated_order_amount'] = 0
        hash["recipe_unit_quantity"] = material.recipe_unit_quantity
        hash["order_unit_quantity"] = material.order_unit_quantity
        hash["vendor_id"] = material.vendor_id
        hash["vendor_name"] = material.vendor.name.truncate(10)
        hash['recipe_unit'] = material.recipe_unit
        hash['order_unit'] = material.order_unit
        hash['delivery_deadline'] = material.delivery_deadline
        hash['order_material_memo'] =''
        hash["vendor_info"] = material.vendor.delivery_date
        hash["vendor_delivery_able_wday"] = material.vendor.delivery_able_wday
        hash["order_criterion"] = mso.order_criterion
        @arr << hash
      end
    elsif params[:calculat_used_pack_order] == 'true'
      order_products = []
      @from = Date.parse(params[:from])
      @to = Date.parse(params[:to])
      @order.memo = "#{@from.strftime("%-m/%-d(#{%w(日 月 火 水 木 金 土)[@from.wday]})")}〜#{@to.strftime("%-m/%-d(#{%w(日 月 火 水 木 金 土)[@to.wday]})")} 製造分"
      @dates =(@from..@to).to_a
      if @dates.count > 7
        redirect_to orders_path(store_id:params[:store_id]),:alert => '期間は7日以内で選択してください。'
      end
      date = params[:make_date]
      @date_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
      @product_hash = {}
      @dates.each do |date|
        sdmds = StoreDailyMenuDetail.joins(:store_daily_menu).where(:store_daily_menus =>{store_id:params[:store_id],start_time:date})
        sdmds.each do |sdmd|
          @date_hash[date][sdmd.product_id] = sdmd.number
          if @product_hash[sdmd.product_id].present?
            @product_hash[sdmd.product_id] += sdmd.number
          else
            @product_hash[sdmd.product_id] = sdmd.number
          end
        end
      end
      @product_hash.each do |bn|
        hash = {}
        hash[:product_id] = bn[0]
        hash[:num] = bn[1]
        hash[:make_date] = date
        order_products << hash
      end
      make_date = @from
    elsif params[:kitchen_days_order] == 'true'
      @from = Date.parse(params[:from])
      @to = Date.parse(params[:to])
      @dates =(@from..@to).to_a
      @order.memo = "#{@from.strftime("%-m/%-d(#{%w(日 月 火 水 木 金 土)[@from.wday]})")}〜#{@to.strftime("%-m/%-d(#{%w(日 月 火 水 木 金 土)[@to.wday]})")} 製造分"
      if @dates.count > 7
        redirect_to orders_path(store_id:params[:store_id]),:alert => '期間は7日以内で選択してください。'
      end
      order_products = []
      bentos_num_h = {}
      DailyMenuDetail.joins(:daily_menu).where(:daily_menus => {start_time:@dates}).each do|dmd|
        if bentos_num_h[dmd.product_id].present?
          bentos_num_h[dmd.product_id]+=dmd.manufacturing_number
        else
          bentos_num_h[dmd.product_id]=dmd.manufacturing_number
        end
      end
      bentos_num_h.each do |bn|
        hash = {}
        hash[:product_id] = bn[0]
        hash[:num] = bn[1]
        hash[:make_date] = @from
        order_products << hash
      end
      make_date = @from
      #vendor絞り込み
      if params[:filter] == "none" || params[:filter].nil?
        vendor_ids = Vendor.all.ids
      elsif params[:filter] == "veg"
        # vendor_ids = [151,489]
        category = ['vege']
      elsif params[:filter] == "meat"
        # vendor_ids = [121,131,21,441,529,509]
        category = ['meat']
      elsif params[:filter] == "not_veg_meat"
        category = ["other_vege","other_food","packed","consumable_item","cooking_item",'fish','rice']
        # vendor_ids = Vendor.where.not(id:[121,131,21,441,529,509,151,489]).ids
      end
    elsif params[:make_date].present?
      order_products = []
      date = params[:make_date]
      bentos_num_h = {}
      DailyMenu.find_by(start_time:date).daily_menu_details.each{|dmd|bentos_num_h[dmd.product_id]=dmd.manufacturing_number}
      bentos_num_h.each do |bn|
        hash = {}
        hash[:product_id] = bn[0]
        hash[:num] = bn[1]
        hash[:make_date] = date
        order_products << hash
      end
      make_date = Date.parse(date)
      @order.memo = "#{make_date.strftime("%-m/%-d(#{%w(日 月 火 水 木 金 土)[make_date.wday]})")} 製造分"
      #vendor絞り込み
      if params[:filter] == "none" || params[:filter].nil?
        vendor_ids = Vendor.all.ids
      elsif params[:filter] == "veg"
        # vendor_ids = [151,489]
        category = ['vege']
      elsif params[:filter] == "meat"
        # vendor_ids = [121,131,21,441,529,509]
        category = ['meat']
      elsif params[:filter] == "not_veg_meat"
        category = ["other_vege","other_food","packed","consumable_item","cooking_item",'fish','rice']
        # vendor_ids = Vendor.where.not(id:[121,131,21,441,529,509,151,489]).ids
      end
    elsif params[:vendor_id].present?
      order_products = []
      make_date = @today
      @materials = Material.where(vendor_id:params[:vendor_id])
      @materials.each do |material|
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
        hash["vendor_name"] = material.vendor.name.truncate(10)
        hash['recipe_unit'] = material.recipe_unit
        hash['order_unit'] = material.order_unit
        hash['delivery_deadline'] = material.delivery_deadline
        hash['order_material_memo'] =''
        hash["vendor_info"] = material.vendor.delivery_date
        hash["vendor_delivery_able_wday"] = material.vendor.delivery_able_wday
        hash["order_criterion"] = ''
        @arr << hash
        if material.target_material_id
          hash = {}
          target_material = Material.find(material.target_material_id)
          hash['material'] = target_material
          hash['make_num'] = 0
          hash['product_id'] = ''
          hash['menu_num'] = {'なし' => 0}
          hash['material_id'] = target_material.id
          hash['calculated_order_amount'] = 0
          hash["recipe_unit_quantity"] = target_material.recipe_unit_quantity
          hash["order_unit_quantity"] = target_material.order_unit_quantity
          hash["vendor_id"] = target_material.vendor_id
          hash["vendor_name"] = target_material.vendor.name.truncate(10)
          hash['recipe_unit'] = target_material.recipe_unit
          hash['order_unit'] = target_material.order_unit
          hash['delivery_deadline'] = target_material.delivery_deadline
          hash['order_material_memo'] =''
          hash["vendor_info"] = target_material.vendor.delivery_date
          hash["vendor_delivery_able_wday"] = target_material.vendor.delivery_able_wday
          hash["order_criterion"] = ''
          @arr << hash
        end
      end

    else
      order_products = []
      make_date = @today
    end
    product_ids = order_products.map{|op|op[:product_id]}
    product_hash = Product.includes(:brand,:product_menus,[menus: [menu_materials: [material:[:vendor]]]]).where(id:product_ids).map{|product|[product.id,product]}.to_h
    order_products.each do |po|
      if po[:product_id].present? && po[:num].to_i > 0
        product = product_hash[po[:product_id]]
        @product_hash[po[:product_id]] = product
        # @product_hash[po[:product_id]] = product.name
        if po[:make_date].present?
          @order.order_products.build(product_id:po[:product_id],serving_for:po[:num],make_date:po[:make_date])
        else
          @order.order_products.build(product_id:po[:product_id],serving_for:po[:num])
        end
        product.menus.each do |menu|
          menu.menu_materials.each do |menu_material|
            if orderable_material_ids.include?(menu_material.material_id)
              if category.present?
                if category.include?(menu_material.material.category)
                  make_hash(menu_material,material_ids,po,product,menu)
                end
              else
                make_hash(menu_material,material_ids,po,product,menu)
              end
            end
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
    material_ids = material_ids.uniq
    @prev_stocks = {}
    @stock_hash = {}
    stocks_hash = Stock.where(store_id:params[:store_id],material_id:material_ids).where("date < ?", make_date).order("date ASC").map{|stock|[stock.material_id,stock]}.to_h
    date = make_date - 1
    stock_hash = {}
    @latest_material_used_amount = {}
    Stock.includes(:material).where(store_id:params[:store_id],material_id:@b_hash.keys,date:(date - 10)..(date + 10)).order('date ASC').map do |stock|
      @latest_material_used_amount[stock.material_id] = 0 unless @latest_material_used_amount[stock.material_id].present?
      if stock_hash[stock.material_id].present?
        stock_hash[stock.material_id] << stock
      else
        stock_hash[stock.material_id] = [stock]
      end
      @latest_material_used_amount[stock.material_id] += stock.used_amount if date > stock.date
    end
    vendors_ids = []
    @b_hash.each do |key,value|
      material = value['material']
      vendors_ids << material.vendor_id
      recipe_unit = value['recipe_unit']
      order_unit = value['order_unit']
      a = []
      value['menu_num'].each{|menu_name, num|a << "#{menu_name}【#{num}食】"}
      menu_name = a.join(',')
      order_material_memo = value['order_material_memo']
      dead_line = value['delivery_deadline']
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
      # クイーンズ、たなか、小田島、ちさんまるしぇ、東中野キッチン、日本パッケージ在庫品、小沢商店
      jogai_vendor_ids = [121,131,151,569]

      no_calculate_vendor_ids = [559,549,261]
      if stocks_hash[key].present?
        if no_calculate_vendor_ids.include?(material.vendor_id)
          order_amount = ((value['calculated_order_amount']/value['recipe_unit_quantity'])*value['order_unit_quantity']).ceil(i)
          un_order_flag = false
          order_quantity_order_unit = order_amount
        elsif jogai_vendor_ids.include?(material.vendor_id)
          if stocks_hash[key].end_day_stock < 0
            shortage_stock = (-1 * stocks_hash[key].end_day_stock).ceil(1)
            order_quantity_order_unit = ((shortage_stock / value['recipe_unit_quantity'].to_f) * value['order_unit_quantity'].to_f).ceil(i)
          else
            un_order_flag = true
            order_quantity_order_unit = 0
          end
        else
          if @latest_material_used_amount[material.id].present?
            if stocks_hash[key].end_day_stock - @latest_material_used_amount[material.id] < 0
              shortage_stock = (@latest_material_used_amount[material.id] - stocks_hash[key].end_day_stock).ceil(1)
              order_quantity_order_unit = ((shortage_stock / value['recipe_unit_quantity'].to_f) * value['order_unit_quantity'].to_f).ceil(i)
            else
              un_order_flag = true
              order_quantity_order_unit = 0
            end
          else
            un_order_flag = true
            order_quantity_order_unit = 0
          end
        end
      else
        order_quantity_order_unit = (calculated_quantity / value['recipe_unit_quantity'].to_f * value['order_unit_quantity'].to_f).ceil(i)
      end

      @order.order_materials.build(material_id:key,recipe_unit:recipe_unit,order_unit:order_unit,order_quantity_order_unit:order_quantity_order_unit,calculated_quantity:calculated_quantity,menu_name:menu_name,order_material_memo:order_material_memo,delivery_date:date,un_order_flag:un_order_flag)

      if stock_hash[key].present?
        material_stock_hash = stock_hash[key].map{|data|[data.date,data]}.to_h
        @thead = ["<th>日付</th>"]
        @tr0 = ["<td>始在庫</td>"]
        @tr1 = ["<td>納品</td>"]
        @tr2 = ["<td>使用</td>"]
        @tr3 = ["<td>終在庫</td>"]
        @tr4 = ["<td>棚卸</td>"]

        (date-10..date+10).each do |day|
          if day.wday == 0 || HolidayJapan.name(day).present?
            color = "color:red;"
          elsif day.wday == 6
            color = "color:blue;"
          else
            color = ""
          end

          if material_stock_hash[day].present?
            stock = material_stock_hash[day]
            zero = "<td style='color:silver;'>0</td>"
            if stock.used_amount == 0
              used_amount = zero
            else
              used_amount = "<td style='color:darkorange;'>- #{(stock.used_amount/stock.material.accounting_unit_quantity).ceil(1)}#{stock.material.accounting_unit}</td>"
            end
            if stock.delivery_amount == 0
              delivery_amount = zero
            else
              delivery_amount = "<td style='color:blue;'>+ #{(stock.delivery_amount/stock.material.accounting_unit_quantity).floor(1)}#{stock.material.accounting_unit}</td>"
            end
            if stock.end_day_stock == 0
              end_day_stock = zero
            elsif stock.end_day_stock < 0
              end_day_stock = "<td style='color:red;'>#{(stock.end_day_stock/stock.material.accounting_unit_quantity).floor(1)}#{stock.material.accounting_unit}</td>"
            else
              end_day_stock = "<td style=''>#{(stock.end_day_stock/stock.material.accounting_unit_quantity).floor(1)}#{stock.material.accounting_unit}</td>"
            end
            if stock.start_day_stock == 0
              start_day_stock = zero
            else
              start_day_stock = "<td style=''>#{(stock.start_day_stock/stock.material.accounting_unit_quantity).floor(1)}#{stock.material.accounting_unit}</td>"
            end

            if stock.inventory_flag == true
              inventory = "<td><span class='label label-success'>棚卸し</span></td>"
            else
              inventory = "<td></td>"
            end
            if stock.date == date
              bc = "background-color:#ffebcd;"
            else
              bc = ""
            end
            @thead << "<th style='text-align:center;#{bc}#{color}'>#{day.strftime("%-m/%-d(#{%w(日 月 火 水 木 金 土)[day.wday]})")}</th>"
            @tr0 << start_day_stock
            @tr1 << delivery_amount
            @tr2 << used_amount
            @tr3 << end_day_stock
            @tr4 << inventory
          else
            @thead << "<th style='text-align:center;#{color}'>#{day.strftime("%-m/%-d(#{%w(日 月 火 水 木 金 土)[day.wday]})")}</th>"
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
    #一旦vendors
    # @vendors = Vendor.all.map{|vendor|[vendor.name,vendor.id]}
    @vendors = Vendor.where(id:vendors_ids.uniq).map{|vendor|[vendor.name,vendor.id]}
  end

  def create
    @stock_hash = {}
    @order = Order.new(order_create_update)
    @code_materials = Material.where(unused_flag:false).where.not(order_code:"")
    @materials = Material.where(unused_flag:false)
    @vendors = @order.order_materials.map{|om|[om.material.vendor.name,om.material.vendor.id]}.uniq
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
    @fax_vendors = Vendor.vendor_fax_index(params)
    @mail_vendors = Vendor.vendor_mail_index(params)
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
         if vendor_id == '549' || vendor_id == '261'
           pdf = NpOrderPdf.new(@materials_this_vendor,@vendor,@order)
         else
           pdf = OrderPdf.new(@materials_this_vendor,@vendor,@order)
         end
         send_data pdf.render,
           filename:    "#{@order.id}_#{@vendor.name}.pdf",
           type:        "application/pdf",
           disposition: "inline"
         end
       end
     else
       redirect_to order_path(@order), danger: "企業を選択してください。"
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
      NotificationMailer.send_fax_order(order,vendor).deliver
    end
    order.order_materials.where(un_order_flag:false).joins(:material).where(:materials =>{vendor_id:vendor_ids}).update_all(status:3)
    redirect_to order, notice: "#{vendors.length} 件のFAXを送信しました。しばらくたったあとにFAXが届いているか確認してください。"
  end
  def send_order_mail
    vendor_ids = params['vendor_id'].keys
    vendors = Vendor.where(id:vendor_ids)
    order = Order.find(params[:order_id])
    vendors.each do |vendor|
      NotificationMailer.send_mail_order(order,vendor).deliver
      Slack::Notifier.new("https://hooks.slack.com/services/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", username: '送信君', icon_emoji: ':face_with_monocle:').ping("【メール送信OK】ID：#{order.id} 発注先：#{vendor.company_name} 担当：#{order.staff_name}")
    end
    order.order_materials.where(un_order_flag:false).joins(:material).where(:materials =>{vendor_id:vendor_ids}).update_all(status:4)
    redirect_to order, notice: "#{vendors.length} 件のメールを送信しました。"
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
  def make_hash(menu_material,material_ids,po,product,menu)
    hash = {}
    if menu_material.temporary_menu_materials.find_by(date:po[:make_date]).present?
      @temporary_menu_materials[menu_material.material_id] = menu_material
    end
    hash['material'] = menu_material.material
    hash['make_num'] = po[:num]
    hash['product_id'] = [product.id]
    hash['menu_num'] = {menu.name => po[:num].to_i}
    hash['material_id'] = menu_material.material_id
    hash['calculated_order_amount'] = (po[:num].to_f * menu_material.amount_used)
    hash["recipe_unit_quantity"] = menu_material.material.recipe_unit_quantity
    hash["order_unit_quantity"] = menu_material.material.order_unit_quantity
    hash["vendor_id"] = menu_material.material.vendor_id
    hash["vendor_name"] = menu_material.material.vendor.name
    hash["vendor_info"] = menu_material.material.vendor.delivery_date
    hash['recipe_unit'] = menu_material.material.recipe_unit
    hash['order_unit'] = menu_material.material.order_unit
    hash['delivery_deadline'] = menu_material.material.delivery_deadline
    hash['order_material_memo'] =''
    hash["vendor_delivery_able_wday"] = menu_material.material.vendor.delivery_able_wday
    @arr << hash
    material_ids << menu_material.material_id
  end
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
    params.require(:order).permit(:store_id,:staff_name,:fixed_flag,:memo,order_materials_attributes: [:id,:calculated_quantity,:order_quantity_order_unit,:order_quantity,
      :menu_name, :order_id, :material_id,:order_material_memo,:delivery_date, :un_order_flag,:_destroy],
      order_products_attributes: [:id,:make_date, :serving_for, :order_id, :product_id, :_destroy])
  end
end
