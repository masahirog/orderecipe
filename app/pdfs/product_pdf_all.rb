
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
      header
      header_lead(product)
      table_content(menus)
      table_right(menus,op)
      start_new_page if i<max_i-1
    end
  end


  def header_lead(product)
    bounding_box([75, 520], :width => 350, :height => 50) do
      text "#{product.name}", size: 9,leading: 3
      text "#{product.cook_category}", size: 9,leading: 3
      text "#{product.cost_price} 円", size: 9,leading: 3
    end
  end
  def header
    bounding_box([0, 520], :width => 60, :height => 50) do
      text "お弁当名:", size: 9,leading: 3,align: :right
      text "調理カテゴリ:", size: 9,leading: 3,align: :right
      text "原価:", size: 9,leading: 3,align: :right
    end
  end

  def table_content(menus)
    bounding_box([0, 480], :width => 520) do
      table line_item_rows(menus), cell_style: { size: 9 } do
      cells.padding = 2
      cells.borders = [:bottom]
      cells.border_width = 0.2
      cells.height = 14
      row(0).border_width = 1
      self.header = true
      self.column_widths = [130,40,140,150,60]
      end
    end
  end
  def line_item_rows(menus)
    data= [["メニュー名","カテゴリ","調理メモ","食材・資材","1人前"]]
    menus.each do |menu|
      u = menu.materials.length
      menu.menu_materials.each_with_index do |mm,i|
        if i == 0
          data << [{:content => "#{menu.name}", :rowspan => u},{:content => "#{menu.category}", :rowspan => u},
            {:content => "#{menu.recipe}", :rowspan => u},"#{Material.find(mm.material_id).name}",
            "#{mm.amount_used} #{Material.find(mm.material_id).calculated_unit}"]
        else
          data << ["#{Material.find(mm.material_id).name}","#{mm.amount_used} #{Material.find(mm.material_id).calculated_unit}"]
        end
      end
    end
    data
  end
  def table_right(menus,op)
    bounding_box([530, 480], :width => 100) do
      table right_item_rows(menus,op), cell_style: { size: 9,align: :right } do
      cells.padding = 2
      cells.borders = [:bottom,]
      cells.border_width = 0.2
      cells.height = 14
      row(0).border_width = 1
      self.header = true
      self.column_widths = [100]
      end
    end
  end
  def right_item_rows(menus,op)
    data= [["#{op.serving_for}人分"]]
    menus.each do |menu|
      u = menu.materials.length
      menu.menu_materials.each_with_index do |mm,i|
        if i == 0
          data << ["#{((mm.amount_used * op.serving_for.to_i).round).to_s(:delimited)} #{Material.find(mm.material_id).calculated_unit}"]
        else
          data << ["#{((mm.amount_used * op.serving_for.to_i).round).to_s(:delimited)} #{Material.find(mm.material_id).calculated_unit}"]
        end
      end
    end
    data
  end
  def sen
    stroke_axis
  end
end
