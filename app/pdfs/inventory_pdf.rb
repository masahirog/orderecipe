class InventoryPdf < Prawn::Document
  def initialize(date,materials,stocks_h)
    super(
      page_size: 'A4',
      margin:10
    )
    #日本語のフォント
    font "vendor/assets/fonts/ipaexg.ttf"
    table_content(date,materials,stocks_h)
  end

  def table_content(date,materials,stocks_h)
    bounding_box([10, 800], :width => 560) do
      text "発行時間：#{Time.now.strftime("%Y年 %m月 %d日　%H:%M")}",size:10,:align => :right
      move_down 10
      table line_item_rows(date,materials,stocks_h) do
        row(0).background_color = 'f5f5f5'
        cells.size = 7
        columns(0).size = 6
        columns(5).size = 8
        cells.border_width = 0.1
        self.header = true
        self.column_widths = [30,100,100,60,60,30,60,80,40]
      end
    end
  end

  def line_item_rows(date,materials,stocks_h)
    data = [['ID','食材名','ひらがな','日付','在庫','単位','直近在庫','仕入先','カテゴリ']]
    storage_places = {"un_saved"=>"未登録","normal"=>"常温","refrigerate"=>"冷蔵",'freezing'=>"冷凍","pack"=>"包材","equipment"=>"備品"}
    materials.each do |material|
      column_values = [material.id,material.name,material.short_name,'','',material.accounting_unit,"#{stocks_h[material.id][2]}\n#{stocks_h[material.id][0].floor(1)}#{material.accounting_unit}",
        material.vendor.name.slice(0..8),storage_places[material.storage_place]]
      data << column_values

    end
    data
  end
end
