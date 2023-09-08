class MenuPdf < Prawn::Document
  def initialize(menu,menu_materials,num)
    # 初期設定。ここでは用紙のサイズを指定している。
    super(
      page_size: 'A4',
      page_layout: :portrait)
    #日本語のフォント
    font "vendor/assets/fonts/ipaexg.ttf"
    text "#{menu.name}　レシピ", size: 12
    move_down 5
    text "【 調理メモ 】", size: 11,styles: :bold
    move_down 2
    text menu.cook_the_day_before, size: 10, :leading => 3
    move_down 5
    if menu.serving_memo.present?
      text "【 盛付メモ 】", size: 11
      move_down 2
      text menu.serving_memo, size: 10
    end
    move_down 3
    table_content(menu_materials,num)
    if menu.menu_processes.present?
      start_new_page
      table_process(menu)
    end
  end


  def table_content(menu_materials,num)
    table line_item_rows(menu_materials,num) do
    cells.padding = 3
    cells.borders = [:bottom]
    cells.border_width = 0.2
    column(-2..-1).align = :right
    row(0).border_width = 1
    row(0).size = 10
    self.header = true
    self.column_widths = [160,20,80,120,60,80]
    end
  end
  def line_item_rows(menu_materials,num)
    data= [["食材","",{:content => "仕込み内容", :colspan => 2},"1人分","#{num}人前"]]
    menu_materials.each_with_index do |mm|
      amount = number_with_precision((mm.amount_used.to_f * num),precision:1, strip_insignificant_zeros: true, delimiter: ',')
      data << [{content:"#{mm.material.name}", size: 9},{content: "#{mm.source_group}", size: 9},{content: "#{mm.post}", size: 9},{content:"#{mm.preparation}", size: 9},
        {content:"#{mm.amount_used} #{mm.material.recipe_unit}", size: 9},{content:"#{amount} #{mm.material.recipe_unit}", size: 10}]
    end
    data
  end


  def table_process(menu)
    table processes_rows(menu) do
    cells.padding = 3
    cells.borders = [:bottom]
    cells.border_width = 0.2
    row(0).border_width = 1
    row(0).size = 10
    self.column_widths = [220,300]
    end
  end
  def processes_rows(menu)
    data= [["工程","画像"]]
    menu.menu_processes.each_with_index do |mp|
      if mp.image.present?
        data << [{content:"#{mp.memo}", size: 11},{:image => open("#{mp.image.url}"), image_width: 280}]
      else
        data << [{content:"#{mp.memo}", size: 11},""]
      end
    end
    data
  end
  def sen
    stroke_axis
  end
end
