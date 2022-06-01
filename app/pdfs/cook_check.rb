class CookCheck < Prawn::Document
  def initialize(daily_menu_id)
    super(
      page_size: 'A4',
      margin:10
    )
    #日本語のフォント
    font "vendor/assets/fonts/ipaexg.ttf"
    daily_menu = DailyMenu.find(daily_menu_id)
    bounding_box([10, 800], :width => 550) do
      text "発行時間：#{Time.now.strftime("%Y年 %m月 %d日　%H:%M")}",size:8,:align => :right
      text "#{daily_menu.start_time.strftime("%-m/%-d (#{%w(日 月 火 水 木 金 土)[daily_menu.start_time.wday]})")} 献立"
      move_down 10
      table_content(daily_menu)
    end
  end

  def table_content(daily_menu)
    table line_item_rows(daily_menu) do
      self.row_colors = ["FFFFFF","E5E5E5"]
      # cells.padding = 6
      cells.size = 9
      # columns(1).size = 10
      # row(0..1).columns(0).size = 10
      cells.border_width = 0.1
      # cells.valign = :center
      self.header = true
      self.column_widths = [150,300,100]
    end
  end

  def line_item_rows(daily_menu)
    data = [['メニュー名','チェック内容','チェック者']]
    daily_menu.daily_menu_details.each_with_index do |dmd,i|
      dmd.product.menus.each do |menu|
        menu.menu_cook_checks.each do |mcc|
          data << [menu.name,mcc.content,'']
        end
      end
    end
    data
  end
end
