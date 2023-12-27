class ProductPdf < Prawn::Document
  def initialize(params,product,menus)
    # 初期設定。ここでは用紙のサイズを指定している。
    super(
      page_size: 'A4',
      page_layout: :landscape)
    #日本語のフォント
    font "vendor/assets/fonts/ipaexg.ttf"
    num = params[:volume][:num]
    product = product
    menus = menus
    header_table(product,num)
    table_content(menus,num)
  end



  def header_table(product,num)
    bounding_box([0, 530], :width => 650) do
      data = [["商品名","製造数"],
              ["#{product.name}","#{num}人分"]]
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

  def table_content(menus,num)
    bounding_box([0, 500], :width => 780) do
      table line_item_rows(menus,num) do
        cells.padding = 2
        cells.borders = [:bottom]
        cells.border_width = 0.2
        column(-1).align = :right
        row(0).border_width = 1
        row(0).size = 9
        self.header = true
        self.column_widths = [270,150,80,40,40,130,65]
      end
    end
  end
  def line_item_rows(menus,num)
    data= [["メニューレシピ","食材","#{num}人分",'グループ',{:content => "仕込み内容", :colspan => 2},"1人分"]]
    menus.each do |menu|
      u = menu.materials.length
      cook_the_day_before_mozi = menu.cook_the_day_before.length
      if cook_the_day_before_mozi<150
        cook_the_day_before_size = 9
      else
        cook_the_day_before_size = 8
      end
      menu.menu_materials.each_with_index do |mm,i|
        if i == 0
          recipe = ""
          if menu.cook_the_day_before.present?
            recipe = "【 前 日 】\n#{menu.cook_the_day_before}\n\n"
          end
          if menu.cook_on_the_day.present?
            recipe += "【 当 日 】\n#{menu.cook_on_the_day}"
          end

          data << [{content: "#{menu.name}\n\n#{recipe}", rowspan: u,size: 9},
            {content:"#{mm.material.name}", size: 9},
            {content:"#{((mm.amount_used * num.to_i).round(1)).to_s(:delimited)} #{mm.material.recipe_unit}",size:9},
            {content:mm.source_group, size: 8},
            {content: "#{mm.post}", size: 7},{content:"#{mm.preparation}", size: 7},
            {content:"#{mm.amount_used} #{mm.material.recipe_unit}", size: 8}
            ]
        else
          data << [{content:"#{mm.material.name}", size: 9},{content:"#{((mm.amount_used * num.to_i).round(1)).to_s(:delimited)} #{mm.material.recipe_unit}",size:9},
            {content:mm.source_group, size: 8},
            {content:"#{mm.post}", size: 7},{content:"#{mm.preparation}", size: 7},
          {content:"#{mm.amount_used} #{mm.material.recipe_unit}", size: 8}]
        end
      end
    end
    data
  end


  def sen
    stroke_axis
  end


end
