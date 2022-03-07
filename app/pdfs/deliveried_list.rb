class DeliveriedList < Prawn::Document
  def initialize(hash)
    super(page_size: 'A4')
    font "vendor/assets/fonts/ipaexg.ttf"
    table_content(hash)
  end
  def table_content(hash)
    bounding_box([0,780], :width => 530) do
      table line_item_rows(hash) do
        # column(-1).align = :right
        # column(2).align = :center
        # column(3).align = :center
        # cells.border_width = 0.2
        cells.size = 9
        self.header = true
        self.column_widths = [200,80,70,170]
      end
    end
  end
  def line_item_rows(hash)
    data= []
    data << ["品名","数量","単位","メモ"]
    hash.each do |material_order_quantity|
      # amount = (om.order_quantity.to_f / om.material.recipe_unit_quantity)
      amount = ActiveSupport::NumberHelper.number_to_rounded((material_order_quantity[1][1] / material_order_quantity[1][0]), strip_insignificant_zeros: true, :delimiter => ',')
      data << [material_order_quantity[1][2],amount,material_order_quantity[1][3],material_order_quantity[1][4]]
    end
    data
  end
end
