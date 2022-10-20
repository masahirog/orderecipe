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
      text "調理 重要管理 実施記録　#{daily_menu.start_time.strftime("%-m/%-d (#{%w(日 月 火 水 木 金 土)[daily_menu.start_time.wday]})")} 献立"
      move_down 10
      table_content(daily_menu,1)
      move_down 10
      text "特記事項"

    end
    start_new_page
    bounding_box([10, 800], :width => 560) do
      text "発行時間：#{Time.now.strftime("%Y年 %m月 %d日　%H:%M")}",size:8,:align => :right
      text "積載 重要管理 実施記録 #{daily_menu.start_time.strftime("%-m/%-d (#{%w(日 月 火 水 木 金 土)[daily_menu.start_time.wday]})")} 献立"
      move_down 10
      table_content(daily_menu,2)
      move_down 10
      text "特記事項"
    end
    start_new_page
    bounding_box([10, 800], :width => 560) do
      text "発行時間：#{Time.now.strftime("%Y年 %m月 %d日　%H:%M")}",size:8,:align => :right
      text "一般衛生管理の実施記録 #{daily_menu.start_time.strftime("%-m/%-d (#{%w(日 月 火 水 木 金 土)[daily_menu.start_time.wday]})")}"
      move_down 10
      eisei_table_content
      move_down 10
      text "特記事項"
    end
    start_new_page
    bounding_box([10, 800], :width => 560) do
      text "発行時間：#{Time.now.strftime("%Y年 %m月 %d日　%H:%M")}",size:8,:align => :right
      text "スタッフ体調管理の実施記録 #{daily_menu.start_time.strftime("%-m/%-d (#{%w(日 月 火 水 木 金 土)[daily_menu.start_time.wday]})")}"
      move_down 10
      taityo_table_content
      move_down 10
      text "げり、おうとのときは、しごとができません。て に きず が あるときは、ばんそうこう と てぶくろ をかならずする。",size:9
      move_down 5
      text "特記事項"
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
          menu.menu_cook_checks.where(check_position:position).each do |mcc|
            data << [dmd.product.name,menu.name,mcc.content,'']
          end
        end
      else
        data << [dmd.product.name,'','','']
      end
    end
    data
  end
  def eisei_table_content
    table eisei_line_item_rows do
      self.row_colors = ["FFFFFF","E5E5E5"]
      # cells.padding = 6
      cells.size = 9
      # columns(1).size = 10
      # row(0..1).columns(0).size = 10
      cells.border_width = 0.1
      # cells.valign = :center
      self.header = true
      self.column_widths = [100,120,50,50,50,190]
    end
  end
  def eisei_line_item_rows
    data = [['項目','確認事項',"いつ",'結果','担当','問題時の応対']]
    data << ["調理スタッフの体調管理","体調、手の傷の有無、着衣等の汚れの確認","始業前","","","・消化器症状（下痢や嘔吐）がある際は調理作業に従事しない\n・手に傷がある場合には絆創膏をつけた上から手袋を着用\n・作業着が汚れている場合は交換"]
    data << ["手洗いの実施","衛生手順の通りの手洗いを行う","作業中","","","・必要なタイミングで手洗いが実施されていない場合は、周りが注意し手洗いを実施"]
    data << ["原材料の受入確認","外観、匂い、包装状態、保存方法、期限等の確認","納品時\n使用前","","","・返品、交換、破棄"]
    data << ["冷蔵庫温度の確認","10℃以下","朝礼後","","","・修理の依頼\n・保管食材の状態確認"]
    data << ["冷凍庫温度の確認","-15℃以下","朝礼後","","","・修理の依頼\n・保管食材の状態確認"]
    data << ["交差汚染","加熱が必要なものと、生食のものが混ざって保管されていないか","作業中","","","・生肉・生魚からの汚染があった場合加熱する、もしくは提供しない"]
    data << ["二次汚染の防止","調理器具は用途別に使い分ける\n扱った都度十分に洗浄する","作業中","","","・調理器具に汚れが残っていた場合、再度洗浄やすすぎを行う"]
    data << ["調理器具の洗浄・消毒・殺菌","使用の都度、調理器具の洗浄や消毒ができているか","作業中","","","再度洗浄やすすぎ、消毒を行う"]
    data << ["トイレの清掃","マニュアル通りの清掃","終業時","","","できていない場合、実施する"]
    data << ["","\n\n","","","",""]
    data << ["","\n\n","","","",""]
    data << ["","\n\n","","","",""]
    data << ["","\n\n","","","",""]
    data << ["","\n\n","","","",""]
    data
  end
  def taityo_table_content
    table taityo_line_item_rows do
      self.row_colors = ["FFFFFF","E5E5E5"]
      # cells.padding = 6
      cells.size = 9
      # columns(1).size = 10
      # row(0..1).columns(0).size = 10
      cells.border_width = 0.1
      cells.height = 22
      cells.align = :center
      self.header = true
      self.column_widths = [200,60,60,60,60,60]
    end
  end
  def taityo_line_item_rows
    data = [['なまえ',"げり","おうと","てのきず","てあらい","ふくそう"]]
    data << ["さんぷる","有 ・[無]","有 ・[無]","有 ・[無]","✓","✓"]
    25.times do |num|
      data << ["","有 ・ 無","有 ・ 無","有 ・ 無","",""]
    end
    data
  end
end
