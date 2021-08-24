class DailyMenuLoadingPdf < Prawn::Document
  def initialize(daily_menu_id)
    super(
      page_size: 'A4',
      margin:10
    )
    #日本語のフォント
    font "vendor/assets/fonts/ipaexg.ttf"
    table_content(daily_menu_id)
  end

  def table_content(daily_menu_id)
    daily_menu = DailyMenu.find(daily_menu_id)
    daily_menu.store_daily_menus.each_with_index do |sdm,i|
      bounding_box([10, 800], :width => 560) do
        text "発行時間：#{Time.now.strftime("%Y年 %m月 %d日　%H:%M")}",size:8,:align => :right
        text "#{sdm.start_time} #{sdm.store.name}"
        move_down 10
        table line_item_rows(sdm) do
          self.row_colors = ["FFFFFF","E5E5E5"]
          # cells.padding = 6
          cells.size = 7
          # columns(1).size = 10
          # row(0..1).columns(0).size = 10
          cells.border_width = 0.1
          # cells.valign = :center
          columns(-2).align = :center
          self.header = true
          self.column_widths = [150,30,80,50,30,50,170]
        end
      end
      start_new_page if i < daily_menu.store_daily_menus.length - 1
    end
  end

  def line_item_rows(sdm)
    data = [['商品名','人前','バーツ名','分量','✓','器','メモ']]
    sdm.store_daily_menu_details.each do |sdmd|
      sdmd.product.product_parts.each do |pp|
        data << [sdmd.product.name,sdmd.number,pp.name,"#{(pp.amount*sdmd.number)} #{pp.unit}","",pp.container,pp.memo]
      end
    end
    data
  end
end
