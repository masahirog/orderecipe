class MenuPdf < Prawn::Document
  def initialize(menu)
    # 初期設定。ここでは用紙のサイズを指定している。
    super(
      page_size: 'A4',
      page_layout: :portrait)
    #日本語のフォント
    font "vendor/assets/fonts/ipaexm.ttf"
    menu = menu
    header_table(menu)
    header_table2(menu)
    table_content(menu)
  end

  # recipe_mozi = menu.recipe.length
  # if recipe_mozi<50
  #   recipe_size = 9
  # elsif recipe_mozi<100
  #   recipe_size = 8
  # elsif recipe_mozi<150
  #   recipe_size = 7
  # else
  #   recipe_size = 6
  # end
  def header_table(menu)
    bounding_box([0, 750], :width => 520) do
      data = [["メニュー名","原価","カテゴリ"],["#{menu.name}","#{menu.cost_price}","#{menu.category}"]]
      table data, cell_style: { size: 10 } do
        cells.padding = 2
        row(0).borders = [:bottom]
        columns(0..3).borders = []
        row(0).columns(0..3).borders = [:bottom]
        row(1).columns(4).borders = [:top]
        cells.border_width = 0.2
        row(0).border_width = 0.5
        self.column_widths = [260,130,130]
      end
    end
  end
  def header_table2(menu)
    bounding_box([0, 710], :width => 520) do
      data=[["調理メモ","盛り付けメモ"],["#{menu.recipe}","#{menu.serving_memo}"]]
      table data, cell_style: { size: 10 } do
        cells.padding = 2
        row(0).borders = [:bottom]
        columns(0..3).borders = []
        row(0).columns(0..3).borders = [:bottom]
        row(1).columns(4).borders = [:top]
        cells.border_width = 0.2
        row(0).border_width = 0.5
        self.header = true
        self.column_widths = [260,260]
      end
    end
  end



  def table_content(menu)
    bounding_box([0, 500], :width => 520) do
      table line_item_rows(menu) do
      cells.padding = 3
      cells.borders = [:bottom]
      cells.border_width = 0.2
      column(-2..-1).align = :right
      row(0).border_width = 1
      row(0).size = 10
      self.header = true
      self.column_widths = [180,80,100,80,70]
      end
    end
  end
  def line_item_rows(menu)
    data= [["食材・資材",{:content => "仕込み内容", :colspan => 2},"1人分","使用原価"]]
    menu.menu_materials.each_with_index do |mm|
        data << [{content:"#{Material.find(mm.material_id).name}", size: 9},{content: "#{mm.post}", size: 9},{content:"#{mm.preparation}", size: 9},
          {content:"#{mm.amount_used} #{Material.find(mm.material_id).calculated_unit}", size: 9},{content:"#{(Material.find(mm.material_id).cost_price * mm.amount_used).round(1)}", size: 9}]
    end
    data
  end
  def sen
    stroke_axis
  end
end
