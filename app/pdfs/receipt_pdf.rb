class ReceiptPdf < Prawn::Document
  def initialize(data)
    super(
      page_size: 'A4',
      :top_margin    => 0 )
    #日本語のフォント
    font "vendor/assets/fonts/ipaexg.ttf"
    body(data)

  end

  def body(data)
    bounding_box([0, 740], :width => 520, :height => 210) do
      stroke_bounds
      move_down 10
      text "領　収　書", size: 20, :align => :center,styles: :bold
      move_down 10
      text "発行日：#{data[0]}　　", size:11, :align => :right
      text "　　#{data[1]} #{data[2]}", size: 16,styles: :bold
      move_down 10
      text "￥　#{data[3]} -", size: 16,styles: :bold, :align => :center
      line [140, 110], [400, 110]
      stroke
      move_down 15
      text "但し、#{data[4]}、上記正に領収いたしました。", size: 11, :align => :center

      move_down 15
      text "　　内　　訳", size: 12
      line [75, 60], [200, 60]
      stroke
      move_down 12
      text "　　税抜金額", size: 12
      line [75, 38], [200, 38]
      stroke
      move_down 12
      text "　　消費税等", size: 12
      line [75, 16], [200, 16]
      stroke
    end

    bounding_box([330, 610], :width => 200, :height => 70) do
      move_down 10
      text "タベル株式会社", size: 11
      text "〒150-0043", size: 11
      text "東京都渋谷区道玄坂2-10-12", size: 11
      text "新大宗ビル3号館9階", size: 11
      text "TEL：03-5539-6000", size: 11
    end

  end


  def sen
    stroke_axis
  end
end
