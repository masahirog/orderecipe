class InventorySheetPdf < Prawn::Document
  def initialize(material_stock)
    super(
      page_size: 'A4',
      margin:10
    )
    #日本語のフォント
    font "vendor/assets/fonts/ipaexg.ttf"
    table_content(material_stock)
  end

  def table_content(material_stock)
    bounding_box([10, 800], :width => 560) do
      text "発行時間：#{Time.now.strftime("%Y年 %m月 %d日　%H:%M")}",size:10,:align => :right
      move_down 10
      table line_item_rows2(material_stock) do
        row(0).background_color = 'f5f5f5'
        # cells.padding = 6
        cells.size = 9
        columns(1..2).size = 7
        columns(-1).size = 7
        row(0).columns(5).size = 7
        # columns(1).size = 10
        # row(0..1).columns(0).size = 10
        #
        cells.border_width = 0.1
        # cells.valign = :center
        # columns(2..-1).align = :center
        self.header = true
        self.column_widths = [180,80,60,60,60,40,80]
      end
    end
  end

  def line_item_rows2(material_stock)
    data = [['食材名','仕入先','在庫予想','実在庫','計上単位','変換']]
    material_stock.each do |ms|
      henkan = ""
      material = ms[1][0]
      recent_stock = ms[1][1]
      if recent_stock == ""
        recent_stock_accounting_unit = ''
      else
        recent_stock_accounting_unit = "#{(ms[1][1]/material.accounting_unit_quantity).floor(1)}#{material.accounting_unit}"
      end
      henkan = "1#{material.accounting_unit}あたり#{material.accounting_unit_quantity}#{material.recipe_unit}"
      data << [material.name,material.vendor.company_name,recent_stock_accounting_unit,'',material.accounting_unit,henkan]
    end
    data
  end
end
