class MasuOrderReceiptPdf < Prawn::Document
  def initialize(data)
    super(
      page_size: 'A4',
      :top_margin    => 0 )
    #日本語のフォント
    font "vendor/assets/fonts/ipaexm.ttf"
    body(data)

  end

  def body(data)
    bounding_box([0, 740], :width => 520, :height => 200) do
      stroke_bounds
      move_down 10
      text "領　収　書", size: 20, :align => :center,styles: :bold
      move_down 10
      text "発行日：#{data[0]}　　", size:11, :align => :right
      text "　　#{data[1]} #{data[2]}", size: 16,styles: :bold
      move_down 10
      text "￥　#{data[3]} -", size: 16,styles: :bold, :align => :center
      line [140, 100], [400, 100]
      stroke
      move_down 15
      text "但し、#{data[4]}として、上記正に領収いたしました。", size: 11, :align => :center

      move_down 10
      text "内　　訳", size: 12
      line [40, 55], [200, 55]
      stroke
      move_down 10
      text "税抜金額", size: 12
      line [40, 33], [200, 33]
      stroke
      move_down 10
      text "消費税等", size: 12
      line [40, 11], [200, 11]
      stroke
    end

    bounding_box([300, 440], :width => 200, :height => 40) do
      stroke_bounds
      move_down 10
      text "領　収　書", size: 20, :align => :center,styles: :bold
    end

  end


  def sen
    stroke_axis
  end
end
