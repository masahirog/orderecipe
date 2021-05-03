class StocksController < AdminController
  # def inventory
  #   @date = Date.parse(params[:date])
  #   @materials = Material.order('vendor_id').search(params).where(unused_flag:false,stock_management_flag:true).includes(:vendor).page(params[:page]).per(20)
  #   stocks = Stock.where(material_id:@materials.ids).where('date <= ?',@date).order("date")
  #   if @materials.present?
  #     @stocks_hash = Stock.where(date:@date,material_id:@materials.ids).map{|stock|[stock.material_id,stock]}.to_h
  #     @stock_hash ={}
  #     @materials.each do |material|
  #       stocks_arr = stocks.where(material_id:material.id).last(5)
  #       aaa(material,@date,stocks_arr)
  #     end
  #   else
  #     @stocks_hash = []
  #   end
  # end

  # def inventory
  #   @materials = Material.includes(:vendor).where(['name LIKE ?', "%#{params["name"]}%"]).page(params[:page]).per(20)
  #   @date = Date.today
  #   stocks = Stock.where(material_id:@materials.ids).where('date <= ?',@date).order("date")
  #   if @materials.present?
  #     @stocks_hash = Stock.where(date:@date,material_id:@materials.ids).map{|stock|[stock.material_id,stock]}.to_h
  #     @stock_hash ={}
  #     @materials.each do |material|
  #       stocks_arr = stocks.where(material_id:material.id).last(5)
  #       aaa(material,@date,stocks_arr)
  #     end
  #   else
  #     @stocks_hash = []
  #   end
  # end
  def vege
    vendor_id = 151
    if params[:date].present?
      @date = Date.strptime(params[:date])
    else
      @date = Date.today
    end
    from = @date - 7
    @materials = Material.joins(:order_materials).where(:order_materials => {delivery_date:from..@date,un_order_flag:false}).where(vendor_id:vendor_id).order(name:'asc').uniq
    render :layout => false
  end
  def upload_inventory_csv
    update_datas_count = Stock.upload_data(params[:file])
    if update_datas_count == 'false'
      redirect_to stocks_path(), :alert => 'csvデータが正しいかどうか確認してください'
    else
      redirect_to stocks_path(), :notice => "#{update_datas_count}件棚卸しを登録しました"
    end
  end

  def update_monthly_stocks
    date = params[:date]
    @month_total_amount = {}
    ids = Material.where(stock_management_flag:true).ids
    stocks = Stock.where(material_id:ids).where("date <= ?", date).order(date: :desc).uniq(&:material_id)
    stocks.delete_if{|stock|stock.end_day_stock <= 0}
    total_amount = 0
    foods_amount = 0
    equipments_amount = 0
    expendables_amount = 0
    stocks.each do |stock|
      material_price = (stock.end_day_stock * stock.material.cost_price)
      if stock.material.category == '食材（肉・魚）'||stock.material.category == '食材（その他）'
        foods_amount += material_price
        total_amount += material_price
      elsif stock.material.category == '包材・商品備品'
        equipments_amount += material_price
        total_amount += material_price
      elsif stock.material.category == 'その他備品・消耗品'
        expendables_amount += material_price
        total_amount += material_price
      end
    end
    item_number = stocks.length
    monthly_stock = MonthlyStock.find_by(date:date)
    monthly_stock.update_attributes(item_number:item_number,total_amount:total_amount.round,foods_amount:foods_amount.round,equipments_amount:equipments_amount.round,expendables_amount:expendables_amount.round)
    redirect_to stocks_path,notice:"#{monthly_stock.date.month}月の棚卸しを更新しました。"
  end
  def index
    @monthly_stocks = MonthlyStock.order('date DESC')
  end
  def new
    @stock = Stock.new
    date = params[:date]
    material_id = params[:material_id]
    @stock.date = date
    @stock.material_id = material_id
    prev_stock = Stock.where("date < ?", date).where(material_id:material_id).order("date DESC").first
    if prev_stock.present?
      @stock.start_day_stock = prev_stock.end_day_stock
      @stock.end_day_stock = prev_stock.end_day_stock
    else
      @stock.start_day_stock = 0
      @stock.end_day_stock = 0
    end
    @stock.used_amount = 0
    @stock.delivery_amount = 0
  end
  def edit
    @stock = Stock.find(params[:id])
    @vendors = Vendor.all
  end
  def show
    @stocks = Stock.find(params[:id])
  end
  def material_info
    @material = Material.find(params[:id])
    respond_to do |format|
      format.html
      format.json
    end
  end

  def create
    @date = Date.today
    @mobile = false
    @mobile = true if params[:stock][:mobile_flag].present?
    update_stocks = []
    if params[:stock][:end_day_stock_accounting_unit] == ""
      # 空欄だと何もしない
    else
      @stock_hash = {}
      @stock = Stock.new(stock_create_update)
      @material = Material.find(params[:stock][:material_id])
      @stock.end_day_stock = params[:stock][:end_day_stock_accounting_unit].to_f*@material.accounting_unit_quantity
      respond_to do |format|
        if @stock.save
          material_update(@date)
          Stock.change_stock(update_stocks,@material.id,@stock.date,@stock.end_day_stock)
          Stock.import update_stocks, on_duplicate_key_update:[:end_day_stock,:start_day_stock,:inventory_flag] if update_stocks.present?
          if params[:stock][:history_flag] == 'true'
            test_hash
            @history_flag = true
            @class_name = ".inventory_tr_#{@stock.id}"
          else
            check_test(@stock)
          end
          format.js
        else
          render 'new'
        end
      end
    end
  end


  def update
    @mobile = false
    @mobile = true if params[:stock][:mobile_flag].present?
    @date = Date.today
    update_stocks = []
    @stock_hash = {}
    @stock = Stock.find(params[:id])
    @material = @stock.material
    end_day_stock_accounting_unit = params[:stock][:end_day_stock_accounting_unit].to_f
    new_end_day_stock = end_day_stock_accounting_unit*@stock.material.accounting_unit_quantity
    new_start_day_stock = new_end_day_stock - @stock.delivery_amount + @stock.used_amount
    inventory_flag = params[:stock][:inventory_flag]
    respond_to do |format|
      if @stock.update(end_day_stock:new_end_day_stock,inventory_flag:inventory_flag,start_day_stock:new_start_day_stock)
        material_update(@date)
        Stock.change_stock(update_stocks,@material.id,@stock.date,new_end_day_stock)
        Stock.import update_stocks, on_duplicate_key_update:[:end_day_stock,:start_day_stock,:inventory_flag] if update_stocks.present?
        if params[:stock][:history_flag] == 'true'
          test_hash
          @history_flag = true
          @class_name = ".inventory_tr_#{@stock.id}"
        else
          check_test(@stock)
        end
        format.js
      else
        format.html { render :new }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end
  end

  def inventory_ajax
    date = params[:date]
    material_id = params[:material_id]
    @stock = Stock.find_or_initialize_by(date: date,material_id:material_id)
  end


  def inventory_update
    new_stocks = []
    update_stocks = []
    date = params[:date]
    stocks_once_update_params.each do |stock_param|
      end_day_stock_accounting_unit = stock_param[1][:end_day_stock]
      if end_day_stock_accounting_unit.present?
        material_id = stock_param[0]
        material = Material.find(material_id)
        end_day_stock = end_day_stock_accounting_unit.to_f*material.accounting_unit_quantity
        stock = Stock.find_by(date:date,material_id:material_id)
        if stock
          stock.end_day_stock = end_day_stock
          stock.inventory_flag = true
          update_stocks << stock
        else
          prev_stock = Stock.where("date < ?", date).where(material_id:material_id).order("date DESC").first
          if prev_stock.present?
            new_stocks << Stock.new(material_id:material_id,date:date,end_day_stock:end_day_stock,start_day_stock:prev_stock.end_day_stock,inventory_flag:true)
          else
            new_stocks << Stock.new(material_id:material_id,date:date,end_day_stock:end_day_stock,inventory_flag:true)
          end
        end
        Stock.change_stock(update_stocks,material_id,date,end_day_stock)
      end
    end
    Stock.import new_stocks if new_stocks.present?
    Stock.import update_stocks, on_duplicate_key_update:[:end_day_stock,:start_day_stock,:inventory_flag] if update_stocks.present?

    redirect_to inventory_stocks_path(date:date,page:params[:page],vendor_id:params[:vendor_id]),
    notice: "<div class='alert alert-success' role='alert' style='font-size:15px;'>在庫を保存しました！</div>".html_safe
  end

  def inventory
    if params[:date]
      @date = DateTime.parse(params[:date])
    else
      @date = Date.today
    end
    if params[:category] == '食材'
      category = ['食材（肉・魚）','食材（その他）']
    else
      category = params[:category]
    end
    @stocks = Stock.where(date:@date).uniq(&:material_id)
    materials = Material.where(stock_management_flag:true)
    materials = materials.where(name:params[:name]) if params[:name].present?
    materials = materials.where(category:category) if params[:category].present?
    ids = materials.ids
    stocks = Stock.where(material_id:ids).where("date <= ?", @date).order(date: :desc)
    @stocks_h = []
    stocks.uniq(&:material_id).each do |stock|
      if stock.end_day_stock > 0
        @stocks_h << [stock.material_id,[(stock.end_day_stock/stock.material.accounting_unit_quantity),(stock.end_day_stock * stock.material.cost_price),stock.date,stock.material.last_inventory_date,stock.material.vendor_id]]
      end
    end
    if params[:order] == '業者'
      @stocks_h = Hash[ @stocks_h.to_h.sort_by{ |_, v| -v[4] } ]
    elsif params[:order] == '棚卸し'
      @stocks_h = Hash[ @stocks_h.to_h.sort_by{ |_, v| -v[3].to_s } ]
    else
      @stocks_h = Hash[ @stocks_h.to_h.sort_by{ |_, v| -v[1] } ]
    end
    respond_to do |format|
      format.html do
        material_ids = @stocks_h.keys
        @materials = Material.where(id:material_ids).order("field(id, #{material_ids.join(',')})").page(params[:page]).per(50)
        @stock_hash ={}
        @materials.each do |material|
          stocks_arr = stocks.where(material_id:material.id).first(5)
          aaa(material,@date,stocks_arr)
        end
      end
      format.csv do
        material_ids = @stocks_h.keys
        @materials = Material.where(id:material_ids).order("field(id, #{material_ids.join(',')})")
        @stock_hash ={}
        send_data render_to_string, filename: "#{Time.now.strftime('%Y%m%d')}_inventory.csv", type: :csv
      end
    end
  end


  def monthly_inventory
    date = params[:date]
    if params[:category] == '食材'
      category = ['食材（肉・魚）','食材（その他）']
    else
      category = params[:category]
    end
    ids = Material.where(category:category).ids
    stocks = Stock.where(material_id:ids).where("date <= ?", date).order(date: :desc).uniq(&:material_id)
    @stocks_h = stocks.map do |stock|
      if stock.end_day_stock > 0
        [stock.material_id,[(stock.end_day_stock/stock.material.accounting_unit_quantity),(stock.end_day_stock * stock.material.cost_price),stock.date]]
      end
    end
    @stocks_h = @stocks_h.compact.to_h
    @stocks_h = Hash[ @stocks_h.sort_by{ |_, v| -v[1] } ]
    material_ids = @stocks_h.keys
    @materials = Material.where(id:material_ids).order("field(id, #{material_ids.join(',')})").page(params[:page]).per(20)
  end

  def history
    @material = Material.find(params[:material_id])
    @history = true
    test_hash
  end

  private
  def stock_create_update
    params.require(:stock).permit(:date,:material_id,:start_day_stock,:end_day_stock,:used_amount,:delivery_amount,:inventory_flag)
  end
  def stocks_once_update_params
    params.require(:stock)
  end

  def test_hash
    today = Date.today
    @stocks = Stock.where(material_id:@material.id).order('date DESC').page(params[:page]).per(20)
    @stocks_hash = @stocks.map{|stock|[stock.date, stock]}.to_h
    @dates = @stocks_hash.keys.sort
    @hash_date = {}
    @hash = {}
    menu_ids = MenuMaterial.where(material_id:@material.id).map{|mm|mm.menu_id}.uniq
    product_ids = ProductMenu.where(menu_id:menu_ids).map{|pm|pm.product_id}.uniq
    @dates.each do |date|
      next_date = date + 1
      KurumesiOrderDetail.joins(:kurumesi_order).where(:kurumesi_orders => {start_time:next_date}).where(product_id:product_ids).map do |mod|
        if @hash[mod.product_id].present?
          @hash[mod.product_id] += mod.number.to_i
        else
          @hash[mod.product_id] = mod.number.to_i
        end
      end
      DailyMenuDetail.joins(:daily_menu).where(:daily_menus => {start_time:next_date}).where(product_id:product_ids).map do |dmd|
        if @hash[dmd.product_id].present?
          @hash[dmd.product_id] += dmd.manufacturing_number.to_i
        else
          @hash[dmd.product_id] = dmd.manufacturing_number.to_i
        end
      end
      @hash_date[date] = "<table><thead><tr><th>#{next_date}</th><th>食数</th></tr></thead><tbody>#{@hash.map{|h|"<tr><td>#{Product.find(h[0]).name}</td><td>#{h[1]}食</td><tr>"}.join('')}</tbody></table>"
      @hash = {}
    end
    @unit = @material.accounting_unit
  end

  def check_test(stock)
    @stocks_info_hash = {}
    update_stocks = []
    Stock.change_stock(update_stocks,stock.material_id,stock.date,stock.end_day_stock)
    Stock.import update_stocks, on_duplicate_key_update:[:end_day_stock,:start_day_stock] if update_stocks.present?
    @material = stock.material
    date = stock.date
    stocks = Stock.where(material_id:@material.id).where('date <= ?',date).order("date DESC")
    stocks_arr = stocks.where(material_id:@material.id).first(5)

    aaa(@material,date,stocks_arr)
    @class_name = ".inventory_tr_#{@material.id}"
    @stocks_hash = {@material.id => stock}
    @stocks_info_hash[@material.id] = [stock.date,stock.end_day_stock,stock.date,stock.material.last_inventory_date]

    @stocks_h = []
    stocks.uniq(&:material_id).each do |stock|
      if stock.end_day_stock > 0
        @stocks_h << [stock.material_id,[(stock.end_day_stock/stock.material.accounting_unit_quantity),(stock.end_day_stock * stock.material.cost_price),stock.date,stock.material.last_inventory_date]]
      end
    end
    @stocks_h = Hash[ @stocks_h.to_h.sort_by{ |_, v| -v[1] } ]
  end

  def aaa(material,date,stocks_arr)
    @stock_hash[material.id] = stocks_arr.map do |stock|
      if stock.used_amount == 0
        used_amount = "<td style='color:silver;'>0</td>"
      else
        used_amount = "<td style='color:red;'>- #{(stock.used_amount/material.accounting_unit_quantity).ceil(1)}#{material.accounting_unit}</td>"
      end
      if stock.delivery_amount == 0
        delivery_amount = "<td style='color:silver;'>0</td>"
      else
        delivery_amount = "<td style='color:blue;'>+ #{(stock.delivery_amount/material.accounting_unit_quantity).floor(1)}#{material.accounting_unit}</td>"
      end
      if stock.end_day_stock == 0
        end_day_stock = "<td style='color:silver;'>0</td>"
      else
        end_day_stock = "<td style=''>#{(stock.end_day_stock/material.accounting_unit_quantity).floor(1)}#{material.accounting_unit}</td>"
      end
      if stock.inventory_flag == true
        inventory = "<td><span class='label label-success'>棚卸し</span></td>"
      else
        inventory = "<td></td>"
      end
      if stock.date >= date
        ["<tr style='background-color:#ffebcd;'><td>#{stock.date.strftime("%Y/%-m/%-d (#{%w(日 月 火 水 木 金 土)[stock.date.wday]})")}</td>#{delivery_amount}#{used_amount}#{end_day_stock}#{inventory}</tr>"]
      else
        ["<tr><td>#{stock.date.strftime("%Y/%-m/%-d (#{%w(日 月 火 水 木 金 土)[stock.date.wday]})")}</td>#{delivery_amount}#{used_amount}#{end_day_stock}#{inventory}</tr>"]
      end
    end
  end

  def history_test

  end

  def material_update(today)
    if @stock.inventory_flag == true
      date = @stock.date
      if @material.last_inventory_date.nil? || @material.last_inventory_date < date
        if today - 30 < date
          @material.update_attributes(need_inventory_flag:false,last_inventory_date:date)
        else
          @material.update_attributes(need_inventory_flag:true,last_inventory_date:date)
        end
      end
    end
  end
end
