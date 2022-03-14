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
      header_adress(vendor,order)
      table_content(arr,date)
      footer(vendor,order,date)
    end
  end

  def header_adress(vendor,order)
    bounding_box([0, 770], :width => 520, :height =>100) do
        font_size 13
        text "日本フードデリバリー　#{order.store.name}　　拠点ID：#{order.store.np_store_code}", :leading => 4
        font_size 10
        text "〒#{order.store.zip}　#{order.store.address}", :leading => 4
        text "TEL：#{order.store.phone} ／ FAX：03-6700-9848", :leading => 8
        # text "オーダーID：#{order.id}", :leading => 5
        font_size 9
        text "下記の通り発注致します。どうぞよろしくお願いいたします。"
    end
  end


  def table_content(arr,date)
    bounding_box([0,700], :width => 530) do
      table line_item_rows(arr,date), cell_style: { size: 9 ,height: 20,:overflow => :shrink_to_fit } do
        row(0).size = 12
        cells.padding = 4
        column(2).align = :center
        column(3).align = :center
        cells.border_width = 0.2
        self.header = true
        self.column_widths = [70,170,70,70,150]
      end
    end
  end
  def line_item_rows(arr,date)
    data= [[{:content => "#{date.strftime("%Y年%-m月%-d日(#{%w(日 月 火 水 木 金 土)[date.wday]})")} 納品分",colspan:5}]]
    data<< ["商品コード","品名",'入数',"数量","備考"]
    arr.each do |mtv|
      s_data = []
      ouq = ActiveSupport::NumberHelper.number_to_rounded(mtv.material.order_unit_quantity, strip_insignificant_zeros: true, :delimiter => ',')
      ruq = ActiveSupport::NumberHelper.number_to_rounded(mtv.material.recipe_unit_quantity, strip_insignificant_zeros: true, :delimiter => ',')
      order_quantity = ActiveSupport::NumberHelper.number_to_rounded(((mtv.order_quantity.to_f/mtv.material.recipe_unit_quantity)*mtv.material.order_unit_quantity).round(1), strip_insignificant_zeros: true, :delimiter => ',')
      data << ["#{mtv.material.order_code}","#{mtv.material.order_name}","#{ouq}#{mtv.material.order_unit} #{ruq}#{mtv.material.recipe_unit}","#{order_quantity}  #{mtv.material.order_unit}","#{mtv.order_material_memo}"]
    end
     data += [["","","","",""]] * 2
  end

  def footer(vendor,order,date)
    move_down 10
    text "株式会社日本パッケージ　御中", size: 13, :leading => 4
    text "FAX：#{vendor.company_fax}　　TEL：#{vendor.company_phone}", size: 10
    move_up 26
    text "発注日：#{Time.now.strftime("%-m月%-d日(#{%w(日 月 火 水 木 金 土)[Time.now.wday]})")}", :leading => 5, size: 14,:align => :right
    text "納品日：#{date.strftime("%-m月%-d日(#{%w(日 月 火 水 木 金 土)[date.wday]})")}", :leading => 5, size: 14,:align => :right
    text "注文担当：#{order.staff_name}", :leading => 5, size: 11,:align => :right
    text "JFDオーダーID：#{order.id}", :leading => 5, size: 10,:align => :right
    move_up 26
    text "【リードタイム】", :leading => 3
    text "月11時までの注文で火納品、水11時までの注文で木納品、金11時までの注文で土納品"

  end
end
