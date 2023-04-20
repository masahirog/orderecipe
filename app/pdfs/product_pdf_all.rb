
class ProductPdfAll < Prawn::Document
  def initialize(id,controller)
    # 初期設定。ここでは用紙のサイズを指定している。
    super(
      page_size: 'A4',
      page_layout: :landscape)
    #日本語のフォント
    font "vendor/assets/fonts/ipaexg.ttf"
    if controller == 'daily_menus'
      daily_menu = DailyMenu.find(id)
      max_i = daily_menu.daily_menu_details.length
      product_ids = daily_menu.daily_menu_details.map{|dmd|dmd.product_id}
      product_menus = ProductMenu.where(product_id:product_ids)
      same_menu_has = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
      product_menus.each do |pm|
        unless pm.menu.category == '容器'
          if same_menu_has[pm.menu_id].present?
            same_menu_has[pm.menu_id]['product_name'] += pm.product.name
            same_menu_has[pm.menu_id]['count'] += 1
          else
            same_menu_has[pm.menu_id]['product_name'] = pm.product.name
            same_menu_has[pm.menu_id]['count'] = 1
          end
        end
      end
      daily_menu.daily_menu_details.each_with_index do |dmd,i|
        product = dmd.product
        menus = product.menus
        alert = ''
        menus.ids.each do |menu_id|
          if same_menu_has[menu_id].present? && same_menu_has[menu_id]['count'] > 1
            alert = "共通メニューの使用があります【#{same_menu_has[menu_id]['product_name']}】"
          end
        end
        num = dmd.manufacturing_number
        chosei = dmd.adjustments
        store_order_number = StoreDailyMenuDetail.joins(:store_daily_menu).where(:store_daily_menus => {daily_menu_id:daily_menu.id}).where(product_id:product.id).sum(:number)
        if alert.present?
          bounding_box([210,540], :width => 550) {
            text alert,size:9
          }
        end
        if menus.map{|menu|menu.menu_processes}.reject { |el| el.empty? }.present?
          bounding_box([0,540], :width => 200) {
            stroke_color 'FFFFFF'
            stroke_bounds
            stroke do
              fill_and_stroke_rounded_rectangle [cursor - 5,cursor + 2], 200, 15, 0
              fill_color '000000'
            end
            text "PC・ipadで写真付き工程を確認して下さい",size:9,color: 'FFFFFF'
          }
        end
        move_down 5
        header_table(product,num,chosei,daily_menu.start_time,store_order_number,max_i,i)
        table_content(daily_menu,menus,num)
        start_new_page if i<max_i-1
      end
    else
      order = Order.find(id)
      max_i = order.order_products.length
      order.order_products.each_with_index do |op,i|
        product = op.product
        menus = product.menus
        num = op.serving_for
        header_date(op.make_date)
        header_table(product,num)
        table_content(menus,num)
        start_new_page if i<max_i-1
      end
    end
  end



  def header_table(product,num,chosei,date,store_order_number,max_i,i)
    if product.carryover_able_flag == true
      kurikoshi = '○'
    else
      kurikoshi = '×'
    end
    if product.freezing_able_flag == true
      reito = '○'
    else
      reito = '×'
    end
    data = [["日付","商品名",'店舗発注合計','製造調整数',"製造数",'翌日繰越','冷凍','発行','ページ'],
            ["#{Date.parse(date.to_s).strftime("%Y年%-m月%-d日(#{%w(日 月 火 水 木 金 土)[Date.parse(date.to_s).wday]})")}","#{product.name}",store_order_number,chosei,num,kurikoshi,reito,DateTime.now.strftime("%m/%d %H:%M"),"#{i+1}/#{max_i}"]]
    table data, cell_style: { size: 9 } do
    cells.padding = 2

    row(0).borders = [:bottom]
    columns(0..-1).borders = []
    row(0).columns(0..-1).borders = [:bottom]
    cells.border_width = 0.2
    cells.height = 14
    self.header = true
    self.column_widths = [100,240,70,70,70,50,40,80,40]
    end
  end



  def table_content(daily_menu,menus,num)
    table line_item_rows(daily_menu,menus,num),:width =>770 do
      cells.padding = 2
      cells.leading = 2
      cells.borders = [:bottom]
      cells.border_width = 0.2
      column(-1).align = :right
      column(5).align = :right
      column(6).align = :center
      column(6).padding = [2,6,2,2]
      row(0).border_width = 1
      row(0).size = 9
      columns(5).size = 11
      self.header = true
      self.column_widths = [90,170,30,30,130,60,50,30,120,60]
      grayout = []
      menuline = []
      values = cells.columns(2).rows(1..-1)
      values.each do |cell|
        grayout << cell.row if cell.content == '◯'
      end
      grayout.map{|num|row(num).column(2..-1).background_color = "dcdcdc"}

    end
  end
  def line_item_rows(daily_menu,menus,num)
    data= [["メニュー名","調理メモ",'✓','変更',"材料名","#{num}人分",'持ち場','G',"仕込み内容","1人分"]]
    date = daily_menu.start_time
    menus.each do |menu|
      unless menu.category == '容器'
        u = menu.materials.length
        cook_the_day_before_mozi = menu.cook_the_day_before.length
        if cook_the_day_before_mozi<100
          cook_the_day_before_size = 9
        elsif cook_the_day_before_mozi<500
          cook_the_day_before_size = 8
        else
          cook_the_day_before_size = 7
        end
        if menu.cook_the_day_before.present? || menu.cook_on_the_day.present?
          cook_memo = "【前日】\n#{menu.cook_the_day_before}\n―・―・―・―・―・―\n【当日】\n#{menu.cook_on_the_day}"
        else
          cook_memo = ''
        end
        
        menu.menu_materials.each_with_index do |mm,i|
          amount = ActiveSupport::NumberHelper.number_to_rounded((mm.amount_used*num), strip_insignificant_zeros: true, :delimiter => ',')
          tmm = mm.temporary_menu_materials.find_by(date:date)
          if tmm.present?
            material_name = tmm.material.name
            change_flag = "◯"
          else
            material_name = mm.material.name
            change_flag = ""
          end
          if i == 0
            data << [{:content => "#{menu.name}", :rowspan => u, size: cook_the_day_before_size},{:content => "#{cook_memo}", :rowspan => u, size: cook_the_day_before_size},'□',
              change_flag,
              {:content => "#{material_name}", size: cook_the_day_before_size },
              {:content => "#{amount} #{mm.material.recipe_unit}", size: cook_the_day_before_size },
              {:content => "#{mm.post}", size: cook_the_day_before_size },
              {:content => "#{mm.source_group}", size: cook_the_day_before_size },
              {:content => "#{mm.preparation}", size: cook_the_day_before_size },
              {:content => "#{mm.amount_used} #{mm.material.recipe_unit}", size: cook_the_day_before_size }]
          else
            data << ['□',change_flag,{:content => "#{material_name}", size: cook_the_day_before_size },
              {:content => "#{amount} #{mm.material.recipe_unit}", size: cook_the_day_before_size },
              {:content => "#{mm.post}", size: cook_the_day_before_size },
              {:content => "#{mm.source_group}", size: cook_the_day_before_size },
              {:content => "#{mm.preparation}", size: cook_the_day_before_size },
              {:content => "#{mm.amount_used} #{mm.material.recipe_unit}", size: cook_the_day_before_size }]
          end
        end
      end
    end
    data
  end

  def sen
    stroke_axis
  end
end
