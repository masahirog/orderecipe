class DeliveriedList < Prawn::Document
  def initialize(order_materials)
    super(page_size: 'A4')
    font "vendor/assets/fonts/ipaexg.ttf"
    table_content(order_materials)
  end
  def table_content(order_materials)
    bounding_box([0,780], :width => 530) do
      table line_item_rows(order_materials) do
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
  def line_item_rows(order_materials)
    data= []
    data << ["品名","数量","単位","メモ"]
    order_materials.each do |om|
      # amount = (om.order_quantity.to_f / om.material.recipe_unit_quantity)
      amount = ActiveSupport::NumberHelper.number_to_rounded((om.order_quantity.to_f / om.material.recipe_unit_quantity), strip_insignificant_zeros: true, :delimiter => ',')
      data << [om.material.order_name,amount,om.material.order_unit,om.order_material_memo]
    end
    data
  end
end
