class MaterialStockSheet < Prawn::Document
  def initialize(from,date,vendor_id)
    super(
      page_size: 'A4',
      margin:10
    )
    #日本語のフォント
    font "vendor/assets/fonts/ipaexg.ttf"
    table_content(from,date,vendor_id)
  end

  def table_content(from,date,vendor_id)
    bounding_box([10, 800], :width => 560) do
      if vendor_id.class == Array
        vendor = Vendor.find(vendor_id[0])
      else
        vendor = Vendor.find(vendor_id)
      end
      materials = Material.joins(:order_materials).where(:order_materials => {delivery_date:from..date,un_order_flag:false}).where(vendor_id:vendor_id).order(name:'asc').uniq
      text "発行時間：#{Time.now.strftime("%Y年 %m月 %d日　%H:%M")}",size:10,:align => :right
      text "#{vendor.company_name}　リスト"
      move_down 10
      table line_item_rows(materials) do
        row(0).background_color = 'f5f5f5'
        # cells.padding = 6
        cells.size = 7
        # columns(1).size = 10
        # row(0..1).columns(0).size = 10
        cells.border_width = 0.1
        # cells.valign = :center
        # columns(2..-1).align = :center
        self.header = true
        self.column_widths = [150,100,150,100]
      end
    end
  end

  def line_item_rows(materials)

    data = [['食材','在庫',"食材名",'在庫']]
    materials.each_slice(2)  do |material_a,material_b|
      if material_b.present?
        data << [material_a.name,'',material_b.name,'']
      else
        data << [material_a.name,'','','']
      end
    end
    data
  end
end
