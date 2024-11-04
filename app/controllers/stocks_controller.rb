class StocksController < AdminController
  def scan
  end
  # def inventory_sheet
  #   date = params[:date]
  #   store_id = params[:store_id]
  #   respond_to do |format|
  #     format.html
  #     format.pdf do
  #       pdf = InventorySheetPdf.new(date,store_id)
  #       send_data pdf.render,
  #       filename:    "#{date}_棚卸し.pdf",
  #       type:        "application/pdf",
  #       disposition: "inline"
  #     end
  #   end
  # end

  def make_this_month
    new_monthly_stocks = []
    date = Date.today.end_of_month
    stores = Store.where(group_id:current_user.group_id)
    stores.each do |store|
      if MonthlyStock.find_by(date:date,store_id:store.id).present?
      else
        new_monthly_stocks << MonthlyStock.new(store_id:store.id,date:date,item_number:0,total_amount:0,foods_amount:0,equipments_amount:0,expendables_amount:0)
      end
    end
    if new_monthly_stocks.present?
      MonthlyStock.import new_monthly_stocks
      redirect_to stocks_path,notice:"#{date.month}月の棚卸し枠を作成しました。"
    else
      redirect_to stocks_path,notice:"#{date.month}月の枠はすでに作成されています。"
    end
  end

  def mobile_inventory
    store_id = params[:store_id]
    @store = Store.find(store_id)
    category = params[:category]

    if params[:date].present?
      @date = Date.parse(params[:date])
    else
      @date = Date.today
    end
    from = @date - 5
    to = @date + 1
    stocks = Stock.joins(:material).where(store_id:store_id).where(:materials => {category:category}).where(date:from..to)
    material_ids = []
    stocks.each do |stock|
      if stock.inventory_flag == true && stock.end_day_stock == 0
      else
        if stock.used_amount == 0
        else
          material_ids << stock.material_id
        end
      end
    end
    material_ids = material_ids.uniq
    stock_hash = {}
    @latest_material_endstock = {}
    stocks.where("date <= ?",@date).order('date ASC').map do |stock|
      val = (stock.end_day_stock / stock.material.accounting_unit_quantity).round(1)
      @latest_material_endstock[stock.material_id] = val
    end
    @materials = Material.where(id:material_ids).order(short_name:'asc')

    @used_amounts = {}
    Stock.where(material_id:material_ids).where(date:to..(to+2)).each do |stock|
      if @used_amounts[stock.material_id].present?
        @used_amounts[stock.material_id] += (stock.used_amount / stock.material.accounting_unit_quantity)
      else
        @used_amounts[stock.material_id] = (stock.used_amount / stock.material.accounting_unit_quantity)
      end
    end
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
    store_id = params[:store_id]
    date = params[:date]
    @month_total_amount = {}
    # ids = Material.where(stock_management_flag:true).ids
    stocks = Stock.where(store_id:store_id).where("date <= ?", date).order(date: :desc).uniq(&:material_id)
    stocks.delete_if{|stock|stock.end_day_stock <= 0}
    total_amount = 0
    foods_amount = 0
    equipments_amount = 0
    expendables_amount = 0
    # food_categories = ["meat","fish","vege","other_vege","other_food",'rice']
    stocks.each do |stock|
      material_price = (stock.end_day_stock * stock.material.cost_price)
      if stock.material.storage_place == "normal" || stock.material.storage_place == "freezing" || stock.material.storage_place == "refrigerate"
        foods_amount += material_price
        total_amount += material_price
      elsif stock.material.storage_place == "pack"
        equipments_amount += material_price
        total_amount += material_price
      elsif stock.material.storage_place == "equipment"
        expendables_amount += material_price
        total_amount += material_price
      end
    end
    item_number = stocks.length
    monthly_stock = MonthlyStock.find_by(date:date,store_id:store_id)
    monthly_stock.update_attributes(item_number:item_number,total_amount:total_amount.round,foods_amount:foods_amount.round,equipments_amount:equipments_amount.round,expendables_amount:expendables_amount.round)
    redirect_to monthly_stocks_path(date:date),notice:"#{monthly_stock.store.name}拠点の#{monthly_stock.date.month}月の棚卸しを更新しました。"
  end
  def store_inventory
    @store = Store.find(params[:store_id])
    @monthly_stocks = MonthlyStock.where(store_id:@store.id).order("date DESC")
    @foods_amount = @monthly_stocks.group(:date,:store_id).sum(:foods_amount)
    @equipments_amount = @monthly_stocks.group(:date,:store_id).sum(:equipments_amount)
    @expendables_amount = @monthly_stocks.group(:date,:store_id).sum(:expendables_amount)
    @item_number = @monthly_stocks.group(:date,:store_id).sum(:item_number)
    @store_item_stocks = ItemStoreStock.where(store_id:params[:store_id]).group(:date).sum(:stock_price)
  end
  def index
    @stores = current_user.group.stores
    monthly_stocks = MonthlyStock.where(store_id:current_user.group.stores.ids)
    @dates = monthly_stocks.map{|ms|ms.date}.uniq.sort.reverse
    @foods_amount = monthly_stocks.group(:date,:store_id).sum(:foods_amount)
    @equipments_amount = monthly_stocks.group(:date,:store_id).sum(:equipments_amount)
    @expendables_amount = monthly_stocks.group(:date,:store_id).sum(:expendables_amount)
    @item_number = monthly_stocks.group(:date,:store_id).sum(:item_number)
    # @monthly_stocks = MonthlyStock.order('date DESC')
  end
  def monthly
    @monthly_stocks = MonthlyStock.includes(:store).where(date:params[:date],store_id:current_user.group.stores.ids)
    @store_item_stocks = ItemStoreStock.where(date:params[:date]).group(:store_id).sum(:stock_price)
  end
  # def new
  #   @stock = Stock.new
  #   date = params[:date]
  #   material_id = params[:material_id]
  #   @stock.date = date
  #   @stock.material_id = material_id
  #   prev_stock = Stock.where("date < ?", date).where(material_id:material_id).order("date DESC").first
  #   if prev_stock.present?
  #     @stock.start_day_stock = prev_stock.end_day_stock
  #     @stock.end_day_stock = prev_stock.end_day_stock
  #   else
  #     @stock.start_day_stock = 0
  #     @stock.end_day_stock = 0
  #   end
  #   @stock.used_amount = 0
  #   @stock.delivery_amount = 0
  # end
  # def edit
  #   @stock = Stock.find(params[:id])
  #   @vendors = Vendor.all
  # end
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
    @to = Date.parse(params[:stock][:date])
    @mobile = false
    @mobile = true if params[:stock][:mobile_flag].present?
    update_stocks = []
    if params[:stock][:end_day_stock_accounting_unit] == ""
      # 空欄だと何もしない
    else
      @stock_hash = {}
      @stock = Stock.new(stock_create_update)
      store_id = @stock.store_id
      @material = Material.find(params[:stock][:material_id])
      @stock.end_day_stock = params[:stock][:end_day_stock_accounting_unit].to_f*@material.accounting_unit_quantity
      @stock.start_day_stock = @stock.end_day_stock
      respond_to do |format|
        if @stock.save
          @end_day_stock = (@stock.end_day_stock / @material.accounting_unit_quantity).round(1)
          @class_name = ".inventory_tr_#{@material.id}"
          Stock.change_stock(update_stocks,@material.id,@stock.date,@stock.end_day_stock,store_id)
          Stock.import update_stocks, on_duplicate_key_update:[:end_day_stock,:start_day_stock,:inventory_flag] if update_stocks.present?
          if params[:stock][:history_flag] == 'true'
            test_hash(store_id)
            @history_flag = true
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
    @scan = false
    @mobile = true if params[:stock][:mobile_flag].present?
    @scan = true if params[:stock][:scan].present?
    update_stocks = []
    @stock_hash = {}
    @stock = Stock.find(params[:id])
    store_id = @stock.store_id
    @to = @stock.date
    @material = @stock.material
    end_day_stock_accounting_unit = params[:stock][:end_day_stock_accounting_unit].to_f
    new_end_day_stock = end_day_stock_accounting_unit*@stock.material.accounting_unit_quantity
    new_start_day_stock = new_end_day_stock - @stock.delivery_amount + @stock.used_amount
    inventory_flag = params[:stock][:inventory_flag]
    respond_to do |format|
      if @stock.update(end_day_stock:new_end_day_stock,inventory_flag:inventory_flag,start_day_stock:new_start_day_stock)
        @end_day_stock = (@stock.end_day_stock / @material.accounting_unit_quantity).round(1)
        Stock.change_stock(update_stocks,@material.id,@stock.date,new_end_day_stock,store_id)
        Stock.import update_stocks, on_duplicate_key_update:[:end_day_stock,:start_day_stock,:inventory_flag] if update_stocks.present?
        @class_name = ".inventory_tr_#{@material.id}"
        if params[:stock][:history_flag] == 'true'
          test_hash(store_id)
          @history_flag = true
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

  # def inventory_ajax
  #   date = params[:date]
  #   material_id = params[:material_id]
  #   @stock = Stock.find_or_initialize_by(date: date,material_id:material_id)
  # end


  # def inventory_update
  #   new_stocks = []
  #   update_stocks = []
  #   date = params[:date]
  #   stocks_once_update_params.each do |stock_param|
  #     end_day_stock_accounting_unit = stock_param[1][:end_day_stock]
  #     if end_day_stock_accounting_unit.present?
  #       material_id = stock_param[0]
  #       material = Material.find(material_id)
  #       end_day_stock = end_day_stock_accounting_unit.to_f*material.accounting_unit_quantity
  #       stock = Stock.find_by(date:date,material_id:material_id)
  #       if stock
  #         stock.end_day_stock = end_day_stock
  #         stock.inventory_flag = true
  #         update_stocks << stock
  #       else
  #         prev_stock = Stock.where("date < ?", date).where(material_id:material_id).order("date DESC").first
  #         if prev_stock.present?
  #           new_stocks << Stock.new(material_id:material_id,date:date,end_day_stock:end_day_stock,start_day_stock:prev_stock.end_day_stock,inventory_flag:true)
  #         else
  #           new_stocks << Stock.new(material_id:material_id,date:date,end_day_stock:end_day_stock,inventory_flag:true)
  #         end
  #       end
  #       Stock.change_stock(update_stocks,material_id,date,end_day_stock,store_id)
  #     end
  #   end
  #   Stock.import new_stocks if new_stocks.present?
  #   Stock.import update_stocks, on_duplicate_key_update:[:end_day_stock,:start_day_stock,:inventory_flag] if update_stocks.present?
  #
  #   redirect_to inventory_stocks_path(date:date,page:params[:page],vendor_id:params[:vendor_id]),
  #   notice: "<div class='alert alert-success' role='alert' style='font-size:15px;'>在庫を保存しました！</div>".html_safe
  # end

  def inventory
    if params[:to]
      @to = Date.parse(params[:to])
    else
      @to = Date.today
    end
    categories = Material.categories
    if params[:categories]
      checked_categories = params['categories'].keys
    else
      checked_categories = categories.keys
      params[:categories] = {}
      checked_categories.each do |category|
        params[:categories][category] = true
      end
    end
    store_id = params[:store_id]
    @store = Store.find(store_id)
    from = @to - 100
    materials = Material.where(category:checked_categories)
    materials = materials.where(storage_place:params[:storage_place]) if params[:storage_place].present?
    material_ids = materials.map{|material|material.id}
    # stocks = Stock.where(store_id:store_id,material_id:material_ids).where(date:from..@to).order(date: :desc)
    # 90日以内には一回は棚卸し等をしているはず
    store_material_hash = MaterialStoreOrderable.where(store_id:store_id,material_id:material_ids).map{|mso|[mso.material_id,mso]}.to_h
    # include(:material)を入れるとめちゃめちゃ重くなる
    stocks = Stock.where(store_id:store_id,material_id:material_ids).where(date:from..@to).order(date: :desc)
    @stocks_hash = {}
    @stocks_h = []
    stocks.uniq(&:material_id).each do |stock|
      @stocks_hash[stock.material_id] = stock
      if store_material_hash[stock.material_id].present?
        last_inventory_date = store_material_hash[stock.material_id].last_inventory_date
      else
        last_inventory_date = ""
      end
      if stock.date == @to
        @stocks_h << [stock.material_id,[(stock.end_day_stock/stock.material.accounting_unit_quantity),(stock.end_day_stock * stock.material.cost_price),stock.date,last_inventory_date,stock.material.vendor_id,stock.material.short_name,stock.material.storage_place,stock.material_id]]
      else
        if stock.end_day_stock == 0 && stock.inventory_flag == true
        else
          @stocks_h << [stock.material_id,[(stock.end_day_stock/stock.material.accounting_unit_quantity),(stock.end_day_stock * stock.material.cost_price),stock.date,last_inventory_date,stock.material.vendor_id,stock.material.short_name,stock.material.storage_place,stock.material_id]]
        end
      end
    end
    if params[:order] == '棚卸分類'
      @stocks_h = Hash[ @stocks_h.to_h.sort_by{ |_, v| [-v[6],-v[4]] } ]
    elsif params[:order] == '五十音'
      @stocks_h = Hash[ @stocks_h.to_h.sort_by{ |_, v| [-v[5],-v[4]] } ]
    elsif params[:order] == '金額'
      @stocks_h = Hash[ @stocks_h.to_h.sort_by{ |_, v| [-v[1],-v[4]] } ]
    else
      @stocks_h = Hash[ @stocks_h.to_h.sort_by{ |_, v| [v[7],-v[4]] } ]
    end
    material_ids = @stocks_h.keys
    respond_to do |format|
      format.html do
        @materials = Material.where(id:material_ids).order("field(id, #{material_ids.join(',')})").page(params[:page]).per(50)
        @stock_hash ={}
        @materials.each do |material|
          stocks_arr = stocks.where(material_id:material.id).first(5)
          aaa(material,@to,stocks_arr)
        end
      end
      format.csv do
        @materials = Material.where(id:material_ids).order("field(id, #{material_ids.join(',')})")
        send_data render_to_string, filename: "#{Time.now.strftime('%Y%m%d')}_inventory.csv", type: :csv
      end
      format.pdf do
        @materials = Material.where(id:material_ids).order("field(id, #{material_ids.join(',')})")
        pdf = InventoryPdf.new(@to,@materials,@stocks_h)
        send_data pdf.render,
        filename:    "#{@to}_棚卸し.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end


  # def monthly_inventory
  #   date = params[:date]
  #   if params[:category] == '食材'
  #     category = ['食材（肉・魚）','食材（その他）']
  #   else
  #     category = params[:category]
  #   end
  #   ids = Material.where(category:category).ids
  #   stocks = Stock.where(material_id:ids).where("date <= ?", date).order(date: :desc).uniq(&:material_id)
  #   @stocks_h = stocks.map do |stock|
  #     if stock.end_day_stock > 0
  #       [stock.material_id,[(stock.end_day_stock/stock.material.accounting_unit_quantity),(stock.end_day_stock * stock.material.cost_price),stock.date]]
  #     end
  #   end
  #   @stocks_h = @stocks_h.compact.to_h
  #   @stocks_h = Hash[ @stocks_h.sort_by{ |_, v| -v[1] } ]
  #   material_ids = @stocks_h.keys
  #   @materials = Material.where(id:material_ids).order("field(id, #{material_ids.join(',')})").page(params[:page]).per(20)
  # end

  def history
    @material = Material.find(params[:material_id])
    @history = true
    store_id = params[:store_id]
    test_hash(store_id)
  end

  private
  def stock_create_update
    params.require(:stock).permit(:date,:material_id,:start_day_stock,:end_day_stock,:used_amount,:delivery_amount,:inventory_flag,:store_id)
  end
  def stocks_once_update_params
    params.require(:stock)
  end

  def test_hash(store_id)
    today = Date.today
    @stocks = Stock.where(store_id:store_id,material_id:@material.id).order('date DESC').page(params[:page]).per(20)
    @stocks_hash = @stocks.map{|stock|[stock.date, stock]}.to_h
    @dates = @stocks_hash.keys
    if @dates.include?(today)
      @dates = @dates.sort
    else
      @dates << today
      @dates = @dates.sort
    end
    @hash_date = {}
    @hash = {}
    menu_ids = MenuMaterial.where(material_id:@material.id).map{|mm|mm.menu_id}.uniq
    product_ids = ProductMenu.where(menu_id:menu_ids).map{|pm|pm.product_id}.uniq
    @dates.each do |date|
      next_date = date + 1
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
    store_id = stock.store_id
    Stock.change_stock(update_stocks,stock.material_id,stock.date,stock.end_day_stock,store_id)
    Stock.import update_stocks, on_duplicate_key_update:[:end_day_stock,:start_day_stock] if update_stocks.present?
    @material = stock.material
    mso = MaterialStoreOrderable.find_by(store_id:store_id,material_id:@material.id)
    date = stock.date
    stocks = Stock.where(material_id:@material.id).where('date <= ?',date).order("date DESC")
    stocks_arr = stocks.where(material_id:@material.id).first(5)
    aaa(@material,date,stocks_arr)
    @stocks_hash = {@material.id => stock}
    @stocks_info_hash[@material.id] = [stock.date,stock.end_day_stock,stock.date,mso.last_inventory_date]

    @stocks_h = []
    store_material_hash = MaterialStoreOrderable.where(store_id:store_id,material_id:@material.id).map{|mso|[mso.material_id,mso]}.to_h
    stocks.uniq(&:material_id).each do |stock|
      if store_material_hash[stock.material_id].present?
        last_inventory_date = ''
      else
        last_inventory_date = store_material_hash[stock.material_id].last_inventory_date
      end
      if stock.end_day_stock >= 0
        @stocks_h << [stock.material_id,[(stock.end_day_stock/stock.material.accounting_unit_quantity),(stock.end_day_stock * stock.material.cost_price),stock.date,last_inventory_date]]
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
end
