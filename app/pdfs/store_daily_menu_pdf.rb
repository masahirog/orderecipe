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
        grayout = []
        values = cells.columns(4).rows(1..-1)
        values.each do |cell|
          if cell.content == ""
          else
            grayout << cell.row
          end
        end
        grayout.map{|num|row(num).column(2..-1).background_color = "DDDDDD"}
        # cells.padding = 6
        cells.size = 7
        # columns(1).size = 10
        # row(0..1).columns(0).size = 10
        cells.border_width = 0.1
        # cells.valign = :center
        # columns(2..-1).align = :center
        self.header = true
        self.column_widths = [180,50,50,50,50,50,50]
      end
    end
  end

  def line_item_rows(store_daily_menu)
    data = [['商品名','味見','製造予定','過不足','朝調理','追加調理','翌日繰越']]
    store_daily_menu_details = StoreDailyMenuDetail.joins(:product).order("products.carryover_able_flag DESC").order(:row_order).where(store_daily_menu_id:store_daily_menu.id)
    store_daily_menu_details.each do |sdmd|
      if sdmd.product.carryover_able_flag == true
        data << [sdmd.product.name,'',sdmd.number,'','','','']
      else
        data << [sdmd.product.name,'',sdmd.number,'',sdmd.number,'','']
      end
    end
    data
  end
end
