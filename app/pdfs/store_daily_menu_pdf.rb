class StoreDailyMenuPdf < Prawn::Document
  def initialize(store_daily_menu_id)
    super(
      page_size: 'A4',
      margin:10
    )
    #日本語のフォント
    font "vendor/assets/fonts/ipaexg.ttf"
    table_content(store_daily_menu_id)
  end

  def table_content(store_daily_menu_id)
    bounding_box([10, 800], :width => 560) do
      store_daily_menu = StoreDailyMenu.find(store_daily_menu_id)
      text "発行時間：#{Time.now.strftime("%Y年 %m月 %d日　%H:%M")}",size:10,:align => :right
      text "#{store_daily_menu.start_time}　#{store_daily_menu.store.name}"
      move_down 10
      table line_item_rows(store_daily_menu) do
        row(0).background_color = 'f5f5f5'
        # cells.padding = 6
        cells.size = 7
        # columns(1).size = 10
        # row(0..1).columns(0).size = 10
        cells.border_width = 0.1
        # cells.valign = :center
        # columns(2..-1).align = :center
        self.header = true
        self.column_widths = [40,180,60,60,60,60,60]
      end
    end
  end

  def line_item_rows(store_daily_menu)

    data = [['No.','商品名','味見','当日ストック','朝調理','追加調理','翌日繰越']]
    store_daily_menu.store_daily_menu_details.each_with_index do |sdmd,i|
      data << [i+1,sdmd.product.name,'',sdmd.number,'','','']
    end
    data
  end
end
