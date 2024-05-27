class ServingList < Prawn::Document
  def initialize(daily_menu)
    super(page_size: 'A4')
    font "vendor/assets/fonts/ipaexg.ttf"
    table_content(daily_menu)
  end
  def table_content(daily_menu)
    bounding_box([0,780], :width => 530) do
      table line_item_rows(daily_menu) do
        cells.size = 9
        self.header = true
        self.column_widths = [150,100,270]
      end
    end
  end
  def line_item_rows(daily_menu)
    data= []
    data << ["品名","包材",'説明']
    daily_menu.daily_menu_details.order(:paper_menu_number).each do |dmd|
      if dmd.product.container.present?
        container = dmd.product.container.name
      else
        container = ""
      end
      data << [dmd.product.food_label_name,container,dmd.product.serving_infomation]
    end
    data
  end
end
