class ProductPdf < Prawn::Document
  def initialize(params,product,menus)
    # 初期設定。ここでは用紙のサイズを指定している。
    super(
      page_size: 'A4',
      page_layout: :landscape)
    #日本語のフォント
    font "vendor/assets/fonts/ipaexm.ttf"
    num = params[:volume][:num]
    product = product
    menus = menus
    header_table(product,num)
    table_content(menus,num)
  end



  def header_table(product,num)
    bounding_box([0, 525], :width => 650) do
      data = [["お弁当名","bento_id","調理カテゴリ","原価","製造数"],
              ["#{product.name}","#{product.bento_id}","#{product.cook_category}","#{product.cost_price} 円","#{num}人分"]]
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
    bounding_box([0, 490], :width => 765) do
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
      recipe_mozi = menu.recipe.length
      if recipe_mozi<50
        recipe_size = 9
      elsif recipe_mozi<100
        recipe_size = 8
      elsif recipe_mozi<150
        recipe_size = 7
      else
        recipe_size = 6
      end
      menu.menu_materials.each_with_index do |mm,i|
        if i == 0
          data << [{content: "#{menu.name}", rowspan: u,size: 9},
            {content: "#{menu.recipe}", rowspan: u, size: recipe_size},
            {content: "#{menu.serving_memo}", rowspan: u, size: 9},{content:"#{mm.material.name}", size: 9},{content: "#{mm.post}", size: 9},{content:"#{mm.preparation}", size: 9},
            {content:"#{mm.amount_used} #{mm.material.calculated_unit}", size: 9},{content:"#{(mm.material.cost_price * mm.amount_used).round(1)}", size: 9},"",
            {content:"#{((mm.amount_used * num.to_i).round).to_s(:delimited)} #{mm.material.calculated_unit}",size:9}]
        else
          data << [{content:"#{mm.material.name}", size: 9},{content:"#{mm.post}", size: 9},{content:"#{mm.preparation}", size: 9},
            {content:"#{mm.amount_used} #{mm.material.calculated_unit}", size: 9},{content:"#{(mm.material.cost_price * mm.amount_used).round(1)}", size: 9},"",
          {content:"#{((mm.amount_used * num.to_i).round).to_s(:delimited)} #{mm.material.calculated_unit}",size:9}]
        end
      end
    end
    data
  end


  def sen
    stroke_axis
  end


end
