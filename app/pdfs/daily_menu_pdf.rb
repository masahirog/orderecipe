class DailyMenuPdf < Prawn::Document
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
        text "発行時間：#{Time.now.strftime("%Y年 %m月 %d日　%H:%M")}",size:10,:align => :right
        text "#{sdm.start_time} #{sdm.store.name}"
        move_down 10
        table line_item_rows(sdm) do
          self.row_colors = ["FFFFFF","E5E5E5"]
          # cells.padding = 6
          cells.size = 7
          # columns(1).size = 10
          # row(0..1).columns(0).size = 10
          cells.border_width = 0.1
          cells.align = :center
          columns(0).align = :left
          columns(-2).align = :center
          self.header = true
          self.column_widths = [180,50,50,50,50,50,50]
        end
        move_down 10

        rows = [['コンテナ','数','メモ'],['　','',''],['　','',''],['　','',''],['　','',''],['　','','']]
        table rows do
          self.column_widths = [180,50,200]
        end
        move_down 5
        text "その他メモ："
      end

      start_new_page if i < daily_menu.store_daily_menus.length - 1
    end
  end

  def line_item_rows(sdm)
    data = [['商品名','副菜','惣菜','','','','']]
    sdm.store_daily_menu_details.each do |sdmd|
      if sdmd.bento_fukusai_number > 0
        fukusai_num = sdmd.bento_fukusai_number
      else
        fukusai_num = ""
      end
      data << [sdmd.product.name,fukusai_num,sdmd.sozai_number,'','','','']
    end
    data
  end
end
