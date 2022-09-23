class CookCheck < Prawn::Document
  def initialize(daily_menu_id)
    super(
      page_size: 'A4',
      margin:10
    )
    #日本語のフォント
    font "vendor/assets/fonts/ipaexg.ttf"
    daily_menu = DailyMenu.find(daily_menu_id)
    bounding_box([10, 800], :width => 560) do
      text "発行時間：#{Time.now.strftime("%Y年 %m月 %d日　%H:%M")}",size:8,:align => :right
      text "調理場仕上がりチェック表　#{daily_menu.start_time.strftime("%-m/%-d (#{%w(日 月 火 水 木 金 土)[daily_menu.start_time.wday]})")} 献立"
      move_down 10
      table_content(daily_menu,1)
    end
    start_new_page
    bounding_box([10, 800], :width => 560) do
      text "発行時間：#{Time.now.strftime("%Y年 %m月 %d日　%H:%M")}",size:8,:align => :right
      text "作業場仕上がりチェック表 #{daily_menu.start_time.strftime("%-m/%-d (#{%w(日 月 火 水 木 金 土)[daily_menu.start_time.wday]})")} 献立"
      move_down 10
      table_content(daily_menu,2)
    end
  end

  def table_content(daily_menu,position)
    table line_item_rows(daily_menu,position) do
      self.row_colors = ["FFFFFF","E5E5E5"]
      # cells.padding = 6
      cells.size = 9
      # columns(1).size = 10
      # row(0..1).columns(0).size = 10
      cells.border_width = 0.1
      # cells.valign = :center
      self.header = true
      self.column_widths = [150,130,200,80]
    end
  end

  def line_item_rows(daily_menu,position)
    data = [['商品名','メニュー名','チェック内容','チェック者']]
    daily_menu.daily_menu_details.each_with_index do |dmd,i|
      if MenuCookCheck.exists?(menu_id:dmd.product.menus.ids,check_position:position)
        dmd.product.menus.each do |menu|
          menu.menu_cook_checks.each do |mcc|
            data << [dmd.product.name,menu.name,mcc.content,'']
          end
        end
      else
        data << [dmd.product.name,'','','']
      end
    end
    data
  end
end
