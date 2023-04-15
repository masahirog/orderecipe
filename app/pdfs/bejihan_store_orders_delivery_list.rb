class BejihanStoreOrdersDeliveryList < Prawn::Document
  def initialize(hash,date)
    super(page_size: 'A4')
    font "vendor/assets/fonts/ipaexg.ttf"
    hash.each_with_index do |store_material_order_list,i|
      text " 納 品 書",:align => :center,:size => 20
      move_down 5
      text "#{Store.find(store_material_order_list[0]).name} 宛",:size => 16
      move_down 10
      text "#{date.strftime("%-m/%-d(#{%w(日 月 火 水 木 金 土)[date.wday]})")} 発注商品一覧"
      table_content(store_material_order_list)
      start_new_page unless i == (hash.length - 1)
    end
  end
  def table_content(store_material_order_list)
    bounding_box([0,700], :width => 555) do
      table line_item_rows(store_material_order_list) do
        cells.size = 9
        column(-4..-3).align = :right
        self.header = true
        self.column_widths = [35,150,50,40,50,50,50,100]
      end
    end
  end
  def line_item_rows(store_material_order_list)
    data= []
    data << ["check","品名","数量","単位","税別単価","金額","担当者","メモ"]
    store_material_order_list[1].each do |material_order_quantity|
      amount = (material_order_quantity[1][1] / material_order_quantity[1][0])*material_order_quantity[1][7]
      amount_to_s = ActiveSupport::NumberHelper.number_to_rounded(amount, strip_insignificant_zeros: true, :delimiter => ',')
      cost = ActiveSupport::NumberHelper.number_to_rounded(material_order_quantity[1][10], strip_insignificant_zeros: true, :delimiter => ',')
      price = ActiveSupport::NumberHelper.number_to_rounded(material_order_quantity[1][10]*amount, strip_insignificant_zeros: true, :delimiter => ',')
      data << ["",material_order_quantity[1][2],amount_to_s,material_order_quantity[1][3],cost,price,material_order_quantity[1][8],material_order_quantity[1][4]]
    end
    data
  end
end
