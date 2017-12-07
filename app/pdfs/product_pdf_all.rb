
class ProductPdfAll < Prawn::Document
  def initialize(order)
    # 初期設定。ここでは用紙のサイズを指定している。
    super(
      page_size: 'A4',
      page_layout: :landscape)
    #日本語のフォント
    font "vendor/assets/fonts/ipaexm.ttf"
    max_i = order.order_products.length
    order.order_products.each_with_index do |op,i|
      product = op.product
      menus = op.product.menus
      num = op.serving_for
      header_date(order)
      header_table(product,num)
      table_content(menus,op)
      start_new_page if i<max_i-1
    end
  end



  def header_table(product,num)
    bounding_box([0, 515], :width => 650) do
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

  def header_date(order)
    bounding_box([0, 525], :width => 200) do
      text "#{order.delivery_date.strftime("　　 　年　 　月　 　日 ( 　　)")}", size: 12,leading: 3
    end
  end


  def table_content(menus,op)
    bounding_box([0, 485], :width => 765) do
      table line_item_rows(menus,op), cell_style: { size: 9 } do
      cells.padding = 2
      cells.borders = [:bottom]
      cells.border_width = 0.2
      cells.height = 14
      column(-2..-1).align = :right
      row(0).border_width = 1
      self.header = true
      self.column_widths = [100,100,100,120,60,100,70,40,5,65]
      end
    end
  end
  def line_item_rows(menus,op)
    data= [["メニュー名","調理メモ","盛付メモ","食材・資材",{:content => "仕込み内容", :colspan => 2},"1人分","使用原価","","#{op.serving_for}人分"]]
    menus.each do |menu|
      u = menu.materials.length
      i = 0
      menu.menu_materials.each do |mm|
        if i == 0
          data << [{:content => "#{menu.name}", :rowspan => u},{:content => "#{menu.recipe}", :rowspan => u},
            {:content => "#{menu.serving_memo}", :rowspan => u},"#{mm.material.name}","#{mm.post}","#{mm.preparation}",
            "#{mm.amount_used} #{mm.material.calculated_unit}","#{(mm.material.cost_price * mm.amount_used).round(1)}",
          "","#{((mm.amount_used * op.serving_for.to_i).round).to_s(:delimited)} #{mm.material.calculated_unit}"]
        else
          data << ["#{mm.material.name}","#{mm.post}","#{mm.preparation}","#{mm.amount_used} #{mm.material.calculated_unit}",
            "#{(mm.material.cost_price * mm.amount_used).round(1)}","","#{((mm.amount_used * op.serving_for.to_i).round).to_s(:delimited)} #{mm.material.calculated_unit}"]
        end
        i += 1
      end
    end
    data
  end

  def sen
    stroke_axis
  end
end
