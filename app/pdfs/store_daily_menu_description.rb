class StoreDailyMenuDescription < Prawn::Document
  def initialize(store_daily_menu)
    super(page_size: 'A4')
    font "vendor/assets/fonts/ipaexg.ttf"
    table_content(store_daily_menu)
  end
  def table_content(store_daily_menu)
    bounding_box([0,780], :width => 530) do
      table line_item_rows(store_daily_menu) do
        cells.size = 9
        self.header = true
        self.column_widths = [200,300]
      end
    end
  end
  def line_item_rows(store_daily_menu)
    data= []
    data << ["品名",'説明']
    store_daily_menu.store_daily_menu_details.each do |sdmd|
      data << [sdmd.product.name,sdmd.product.description]
    end
    data
  end
end
