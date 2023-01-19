class NpOrderPdf < Prawn::Document
  def initialize(materials_this_vendor,vendor,order)
    super(page_size: 'A4')
    uniq_date = materials_this_vendor.pluck(:delivery_date).uniq
    font "vendor/assets/fonts/ipaexg.ttf"
    uniq_date.each_with_index do |date,i|
      arr=[]
      materials_this_vendor.each do |material|
        arr << material if material.delivery_date == date
      end
      start_new_page unless i == 0
      # header_lead(vendor)
      header_adress(vendor,order,date)
      table_content(arr,date)
      footer(vendor,order,date)
    end
  end

  def header_adress(vendor,order,date)
    bounding_box([0, 770], :width => 530, :height =>100) do
        font_size 13
        text "#{order.store.name} 様 ご注文書", :leading => 4,size:15
        move_down 2
        stroke_horizontal_line 0, 530
        move_down 5
        font_size 9
        text "〒#{order.store.zip}　#{order.store.address}", :leading => 4
        # text "オーダーID：#{order.id}", :leading => 5
    end
    bounding_box([0, 770], :width => 530, :height =>100) do
        font_size 15
        np_store_code = order.store.np_store_code
        text "#{np_store_code}", :leading => 4,:align => :right
    end
    bounding_box([0, 744], :width => 530, :height =>100) do
        font_size 9
        text "Tel：#{order.store.phone} / Fax：03-6837-5337", :leading => 8,:align => :right
    end
  end


  def table_content(arr,date)
    bounding_box([0,720], :width => 530) do
      table line_item_rows(arr,date), cell_style: { size: 9 ,height: 20,:overflow => :shrink_to_fit } do
        cells.padding = 4
        column(2).align = :center
        column(3).align = :center
        column(4).align = :center
        cells.border_width = 0.2
        self.header = true
        self.column_widths = [70,170,70,70,150]
      end
    end
  end
  def line_item_rows(arr,date)
    data = [["商品コード","品名",'入数',"発注数量","備考"]]
    arr.each do |mtv|
      s_data = []
      ouq = ActiveSupport::NumberHelper.number_to_rounded(mtv.material.order_unit_quantity, strip_insignificant_zeros: true, :delimiter => ',')
      ruq = ActiveSupport::NumberHelper.number_to_rounded(mtv.material.recipe_unit_quantity, strip_insignificant_zeros: true, :delimiter => ',')
      order_quantity = ActiveSupport::NumberHelper.number_to_rounded(((mtv.order_quantity.to_f/mtv.material.recipe_unit_quantity)*mtv.material.order_unit_quantity).round(1), strip_insignificant_zeros: true, :delimiter => ',')
      data << ["#{mtv.material.order_code}","#{mtv.material.order_name}","#{ruq} #{mtv.material.recipe_unit}/#{mtv.material.order_unit}","#{order_quantity}  #{mtv.material.order_unit}","#{mtv.order_material_memo}"]
    end
     data += [["","","","",""]] * 2
  end

  def footer(vendor,order,date)
    move_down 10
    text "株式会社日本パッケージ　御中", size: 13, :leading => 4
    text "FAX：#{vendor.company_fax}", :leading => 6, size: 12
    text "TEL：#{vendor.company_phone}", :leading => 6, size: 11
    move_up 50
    text "＜リードタイム＞　月 〜11:00 ご注文 → 火 納品", :leading => 5, size: 10,:align => :right
    text "水 〜11:00 ご注文 → 木 納品", :leading => 5, size: 10,:align => :right
    text "金 〜11:00 ご注文 → 土 納品", :leading => 5, size: 10,:align => :right
    move_down 5
    text "発注日：#{Time.now.strftime("%-m月%-d日(#{%w(日 月 火 水 木 金 土)[Time.now.wday]})")}", :leading => 7, size: 14,:align => :right
    text "納品日：#{date.strftime("%-m月%-d日(#{%w(日 月 火 水 木 金 土)[date.wday]})")}", :leading => 7, size: 14,:align => :right
    text "注文担当：#{order.staff_name}", :leading => 7, size: 11,:align => :right
    text "JFDオーダーID：#{order.id}", :leading => 7, size: 10,:align => :right
  end

  def sen
    stroke_axis
  end
end
