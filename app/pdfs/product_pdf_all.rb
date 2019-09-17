
class ProductPdfAll < Prawn::Document
  def initialize(id,controller)

    # 初期設定。ここでは用紙のサイズを指定している。
    super(
      page_size: 'A4',
      page_layout: :landscape)
    #日本語のフォント
    font "vendor/assets/fonts/ipaexm.ttf"
    if controller == 'daily_menus'
      daily_menu = DailyMenu.find(id)

      max_i = daily_menu.daily_menu_details.length
      daily_menu.daily_menu_details.each_with_index do |dmd,i|
        product = dmd.product
        menus = product.menus
        num = dmd.manufacturing_number
        header_date(daily_menu.start_time)
        header_table(product,num)
        table_content(menus,num)
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



  def header_table(product,num)
    bounding_box([0, 515], :width => 650) do
      data = [["お弁当名","management_id","調理カテゴリ","原価","製造数"],
              ["#{product.name}","#{product.management_id}","#{product.cook_category}","#{product.cost_price} 円","#{num}人分"]]
      table data, cell_style: { size: 9 } do
      cells.padding = 2

      row(0).borders = [:bottom]
      columns(0..3).borders = []
      row(0).columns(0..3).borders = [:bottom]
      row(1).columns(4).borders = [:top]
      cells.border_width = 0.2
      cells.height = 14
      self.header = true
      self.column_widths = [250,100,100,100,100]
      end
    end
  end

  def header_date(date)
    bounding_box([0, 525], :width => 200) do
      text "#{Date.parse(date.to_s).strftime("%Y年%-m月%-d日(#{%w(日 月 火 水 木 金 土)[Date.parse(date.to_s).wday]})")}", size: 12,leading: 3
    end
  end


  def table_content(menus,num)
    bounding_box([0, 485], :width => 765) do
      table line_item_rows(menus,num) do
      cells.padding = 2
      cells.borders = [:bottom]
      cells.border_width = 0.2
      column(-2..-1).align = :right
      row(0).border_width = 1
      row(0).size = 9
      self.header = true
      self.column_widths = [100,100,100,120,60,100,70,40,5,65]
      end
    end
  end
  def line_item_rows(menus,num)
    data= [["メニュー名","調理メモ","盛付メモ","食材・資材",{:content => "仕込み内容", :colspan => 2},"1人分","使用原価","","#{num}人分"]]
    menus.each do |menu|
      u = menu.materials.length
      cook_the_day_before_mozi = menu.cook_the_day_before.length
      if cook_the_day_before_mozi<50
        cook_the_day_before_size = 9
      elsif cook_the_day_before_mozi<100
        cook_the_day_before_size = 8
      elsif cook_the_day_before_mozi<150
        cook_the_day_before_size = 7
      else
        cook_the_day_before_size = 6
      end
      menu.menu_materials.each_with_index do |mm,i|
        if i == 0
          data << [{:content => "#{menu.name}", :rowspan => u, size: cook_the_day_before_size},{:content => "#{menu.cook_the_day_before}", :rowspan => u, size: cook_the_day_before_size},
            {:content => "#{menu.serving_memo}", :rowspan => u, size: cook_the_day_before_size },{:content => "#{mm.material.name}", size: cook_the_day_before_size },{:content => "#{mm.post}", size: cook_the_day_before_size },{:content => "#{mm.preparation}", size: cook_the_day_before_size },
            {:content => "#{mm.amount_used} #{mm.material.recipe_unit}", size: cook_the_day_before_size },{:content => "#{(mm.material.cost_price * mm.amount_used).round(1)}", size: cook_the_day_before_size },
          "",{:content => "#{((mm.amount_used * num.to_i).round).to_s(:delimited)} #{mm.material.recipe_unit}", size: cook_the_day_before_size }]
        else
          data << [{:content => "#{mm.material.name}", size: cook_the_day_before_size },{:content => "#{mm.post}", size: cook_the_day_before_size },{:content => "#{mm.preparation}", size: cook_the_day_before_size },{:content => "#{mm.amount_used} #{mm.material.recipe_unit}", size: cook_the_day_before_size },
            {:content => "#{(mm.material.cost_price * mm.amount_used).round(1)}", size: cook_the_day_before_size },"",{:content => "#{((mm.amount_used * num.to_i).round).to_s(:delimited)} #{mm.material.recipe_unit}", size: cook_the_day_before_size }]
        end
      end
    end
    data
  end

  def sen
    stroke_axis
  end
end
