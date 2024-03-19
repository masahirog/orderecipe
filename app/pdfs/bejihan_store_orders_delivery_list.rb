class BejihanStoreOrdersDeliveryList < Prawn::Document
  def initialize(hash,date,items_hash)
    super(page_size: 'A4')
    font "vendor/assets/fonts/ipaexg.ttf"
    hash.each_with_index do |store_material_order_list,i|
      store_id = store_material_order_list[0]
      items_data = items_hash[store_id]
      text " 納 品 書",:align => :center,:size => 20
      move_down 5
      text "#{Store.find(store_material_order_list[0]).name} 宛",:size => 16
      move_down 10
      text "#{date.strftime("%-m/%-d(#{%w(日 月 火 水 木 金 土)[date.wday]})")} 発注商品一覧"
      table_content(store_material_order_list,items_data)
      start_new_page unless i == (hash.length - 1)
    end
  end
  def table_content(store_material_order_list,items_data)
    bounding_box([0,700], :width => 555) do
      table line_item_rows(store_material_order_list) do
        cells.size = 9
        column(-4..-3).align = :right
        self.header = true
        self.column_widths = [35,150,50,40,50,50,50,100]
      end
      if items_data.present?
        move_down 10
        text "物産品"
        move_down 5
        table item_line_item_rows(items_data) do
          cells.size = 9
          column(-4..-3).align = :right
          self.header = true
          self.column_widths = [35,150,50,40,50,50,50,100]
        end
      end
    end
  end
  def line_item_rows(store_material_order_list)
    data= []
    data << ["check","品名","数量","単位","税別単価","金額","担当者","メモ"]
    store_material_order_list[1].each do |material_order_quantity|
      rowspan = material_order_quantity[1][:orders].count
      material = material_order_quantity[1][:material]
      amount = (material_order_quantity[1][:order_quantity] / material.recipe_unit_quantity)*material.order_unit_quantity
      amount_to_s = ActiveSupport::NumberHelper.number_to_rounded(amount, strip_insignificant_zeros: true, :delimiter => ',')
      cost = ActiveSupport::NumberHelper.number_to_rounded(material.recipe_unit_price.round, strip_insignificant_zeros: true, :delimiter => ',')
      price = ActiveSupport::NumberHelper.number_to_rounded(material.recipe_unit_price.round*amount, strip_insignificant_zeros: true, :delimiter => ',')
      material_order_quantity[1][:orders].each_with_index do |order_material,i|
        if i == 0
          data << [{:content => "", :rowspan => rowspan},{:content => material.order_name, :rowspan => rowspan},{:content => amount_to_s, :rowspan => rowspan},{:content => material.order_unit, :rowspan => rowspan},{:content => cost, :rowspan => rowspan},{:content => price, :rowspan => rowspan},order_material[1][:order].staff_name,order_material[1][:memo]]
        else
          data << [order_material[1][:order].staff_name,order_material[1][:memo]]
        end
      end
    end
    data
  end


  def item_line_item_rows(items_data)
    data = []
    data << ["check","品名","数量","単位","税別単価","金額","担当者","メモ"]
    items_data.each do |item_order_data|
      cost = ""
      price = ""
      rowspan = item_order_data[1][:item_order_item].length
      item_order_data[1][:item_order_item].each_with_index do |ioi_data,i|
        if i == 0
          data << [{:content => "", :rowspan => rowspan},{:content => item_order_data[1][:attribute].name, :rowspan => rowspan},{:content => "#{item_order_data[1][:order_quantity]}", :rowspan => rowspan},{:content => item_order_data[1][:attribute].unit, :rowspan => rowspan},{:content => cost, :rowspan => rowspan},{:content => price, :rowspan => rowspan},ioi_data[1][:item_order].staff_name,ioi_data[1][:attribute].memo]
        else
          data << [ioi_data[1][:item_order].staff_name,ioi_data[1][:attribute].memo]
        end
      end
    end
    data
  end

end
