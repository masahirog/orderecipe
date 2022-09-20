class CookOnTheDay < Prawn::Document
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
        text "当日調理工程一覧："
        move_down 5
        table cook_on_the_day(sdm) do
          self.row_colors = ["FFFFFF","E5E5E5"]
          cells.size = 7
          cells.border_width = 0.1
          columns(-5..-4).align = :center
          self.header = true
          self.column_widths = [140,90,40,40,130,40,40,40]
        end
        move_down 10
        text "朝調理個数一覧："
        move_down 5
        table line_item_rows(sdm) do
          self.row_colors = ["FFFFFF","E5E5E5"]
          cells.size = 7
          cells.border_width = 0.1
          columns(1..-1).align = :center
          self.header = true
          self.column_widths = [180,50,50,100,100]
        end
        move_down 10
        text "その他メモ："
      end
      start_new_page if i < daily_menu.store_daily_menus.length - 1
    end
  end
  def cook_on_the_day(sdm)
    data = [['商品名','品目','合計','朝数','工程','中心温','調理✓','積載✓']]
    sdm.store_daily_menu_details.each do |sdmd|
      if sdmd.product.carryover_able_flag == true
        number = "※ " + (sdmd.number*0.7).ceil.to_s
      else
        number = sdmd.number
      end
      sdmd.product.menus.each do |menu|
        menu.menu_last_processes.each do |mlp|
          data << [sdmd.product.name,mlp.content,sdmd.number,number,mlp.memo,'','','']
        end
      end
    end
    data
  end


  def line_item_rows(sdm)
    data = [['商品名','翌日繰越','冷凍保存',sdm.store.name,'朝調理分']]
    sdm.store_daily_menu_details.each do |sdmd|
      if sdmd.product.carryover_able_flag == true
        if sdmd.product.freezing_able_flag == true
          reito = '○'
        else
          reito = ''
        end
        morning_number = "※　" + (sdmd.number*0.7).ceil.to_s
        data << [sdmd.product.name,'○',reito,sdmd.number,morning_number]
      else
      end
    end
    data
  end
end
