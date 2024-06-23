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
    tpm = TemporaryProductMenu.where(daily_menu_detail_id:daily_menu.daily_menu_details.ids).map{|tpm|[tpm.product_menu_id,tpm]}.to_h
    store_daily_menus = daily_menu.store_daily_menus.joins(:store).where(:stores => {group_id:9})
    store_daily_menus.includes(:store,store_daily_menu_details:[:product]).each_with_index do |sdm,i|
      bounding_box([10, 800], :width => 560) do
        text "※この紙はべじはん新高円寺店に納品してください",size:10 if sdm.store_id == 154 ||sdm.store_id == 29
        text "発行：#{Time.now.strftime("%Y年 %m月 %d日　%H:%M")}",size:8,:align => :right
        text "#{sdm.start_time} 当日調理工程表",:align => :center,size:14
        move_down 10
        text "#{sdm.store.name}店"
        move_down 5
        table cook_on_the_day(sdm,tpm) do
          self.row_colors = ["FFFFFF","E5E5E5"]
          cells.size = 7
          cells.border_width = 0.1
          columns(-5..-4).align = :center
          columns(3).size = 12
          rows(0).size = 8
          self.header = true
          self.column_widths = [140,90,40,40,130,40,40,40]
        end
        move_down 10
        text "その他メモ："
      end
      start_new_page if i < store_daily_menus.length - 1
    end
  end
  def cook_on_the_day(sdm,tpm)
    data = [['商品名','品目','製造数','朝調理','工程','中心温','調理✓','積載✓']]
    sdm.store_daily_menu_details.each do |sdmd|
      if sdmd.carry_over > 0
        morning_number = "※ " + sdmd.actual_inventory.to_s
      else
        morning_number = sdmd.number
      end
      sdmd.product.product_menus.each do |pm|
        if tpm[pm.id].present?
          menu = tpm[pm.id].menu
        else
          menu = pm.menu
        end
        menu.menu_last_processes.each do |mlp|
          data << [sdmd.product.name,mlp.content,sdmd.number,morning_number,mlp.memo,'','','']
        end
      end
    end
    data
  end
end
