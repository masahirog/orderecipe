class SourcesPdf < Prawn::Document
  def initialize(date,controller)

    # 初期設定。ここでは用紙のサイズを指定している。
    super(
      page_size: 'A4',
      page_layout: :landscape)
    #日本語のフォント
    font "vendor/assets/fonts/ipaexg.ttf"
    daily_menu = DailyMenu.find_by(start_time:date)
    max_i = daily_menu.daily_menu_details.length
    daily_menu.daily_menu_details.each_with_index do |dmd,i|
      product = dmd.product
      menus = product.menus
      num = dmd.manufacturing_number
      header_table(product,num,daily_menu.start_time)
      table_content(menus,num)
      start_new_page if i<max_i-1
    end
  end

  def header_table(product,num,date)
    bounding_box([0, 525], :width => 650) do
      data = [["日付","商品名","製造数"],
              ["#{Date.parse(date.to_s).strftime("%Y年%-m月%-d日(#{%w(日 月 火 水 木 金 土)[Date.parse(date.to_s).wday]})")}","#{product.name}","#{num}人分"]]
      table data, cell_style: { size: 9 } do
      cells.padding = 2

      row(0).borders = [:bottom]
      columns(0..3).borders = []
      row(0).columns(0..3).borders = [:bottom]
      row(1).columns(4).borders = [:top]
      cells.border_width = 0.2
      cells.height = 14
      self.header = true
      self.column_widths = [100,250,100]
      end
    end
  end

  def table_content(menus,num)
    bounding_box([-10, 495], :width => 790) do
      table line_item_rows(menus,num) do
        cells.padding = 2
        cells.leading = 2
        cells.borders = [:bottom]
        cells.border_width = 0.2
        column(-1).align = :right
        column(3).align = :right
        column(4).align = :center
        column(4).padding = [2,6,2,2]
        row(0).border_width = 1
        row(0).size = 9
        cells.columns(5).rows(0).size = 6
        columns(4).size = 11
        self.header = true
        self.column_widths = [100,190,40,140,70,30,150,60]
        grayout = []
        menuline = []
        values = cells.columns(2).rows(1..-1)
        values.each do |cell|
          grayout << cell.row unless cell.content == 'タレ'
        end
        grayout.map{|num|row(num).column(2..-1).background_color = "dcdcdc"}
      end
    end
  end
  def line_item_rows(menus,num)
    data= [["メニュー名","調理メモ",'担当',"食材・資材","#{num}人分","グループ","仕込み内容","1人分"]]
    menus.each do |menu|
      u = menu.materials.length
      cook_the_day_before_mozi = menu.cook_the_day_before.length
      if cook_the_day_before_mozi<50
        cook_the_day_before_size = 10
      elsif cook_the_day_before_mozi<100
        cook_the_day_before_size = 9
      elsif cook_the_day_before_mozi<150
        cook_the_day_before_size = 8
      else
        cook_the_day_before_size = 7
      end
      menu.menu_materials.each_with_index do |mm,i|
        if menu.cook_the_day_before.present? || menu.cook_on_the_day.present?
          cook_memo = "【前日】\n#{menu.cook_the_day_before}\n―・―・―・―・―・―\n【当日】\n#{menu.cook_on_the_day}"
        else
          cook_memo = ''
        end
        if i == 0
          data << [{:content => "#{menu.name}", :rowspan => u, size: 9},{:content => "#{cook_memo}", :rowspan => u, size: cook_the_day_before_size},
            {:content => "#{mm.post}", size: 8 },
            {:content => "#{mm.material.name}", size: 9 },
            {:content => "#{ActiveSupport::NumberHelper.number_to_rounded((mm.amount_used * num.to_i).round(1), strip_insignificant_zeros: true)} #{mm.material.recipe_unit}", size: 9 },
            {:content => "#{mm.source_group}", size:9,:align => :center },
            {:content => "#{mm.preparation}", size:9 },
            {:content => "#{mm.amount_used} #{mm.material.recipe_unit}", size: 9 }]
        else
          data << [{:content => "#{mm.post}", size: 8 },{:content => "#{mm.material.name}", size: 9 },
            {:content => "#{ActiveSupport::NumberHelper.number_to_rounded((mm.amount_used * num.to_i).round(1), strip_insignificant_zeros: true)} #{mm.material.recipe_unit}"},
            {:content => "#{mm.source_group}", size:9,:align => :center },
            {:content => "#{mm.preparation}", size: 9 },
            {:content => "#{mm.amount_used} #{mm.material.recipe_unit}", size: 9 }]
        end
      end
    end
    data
  end

  def sen
    stroke_axis
  end
end
