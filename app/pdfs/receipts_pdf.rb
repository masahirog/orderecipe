class ReceiptsPdf < Prawn::Document
  def initialize(data,stamp)
    super(
      page_size: 'A4',
      :top_margin    => 0 )
    #日本語のフォント
    font "vendor/assets/fonts/ipaexg.ttf"
    n=1
    data.each do |id,arr|
      body(id,arr,stamp)
      if n < data.length
        start_new_page
        n += 1
      end
    end

  end

  def body(id,arr,stamp)
    if arr[0]==0
      move_down 10
      image open(arr[1]), at: [-50, 750], width: 620
      image 'app/assets/images/taberu_stamp.png', at: [440, 630], width: 60 if stamp == "true"
    else
      bounding_box([0, 740], :width => 520, :height => 225) do
        stroke_bounds
        move_down 10
        text "領　収　書", size: 20, :align => :center,styles: :bold
        move_down 10
        text "発行日：#{arr[1]}　　", size:11, :align => :right
        move_down 5
        text "オーダーID：#{id}　　", size:11, :align => :right
        if arr[1].present?
          if arr[1].length > 20
            text "　　#{arr[2]} #{arr[3]}", size: 12,styles: :bold
          else
            text "　　#{arr[2]} #{arr[3]}", size: 16,styles: :bold
          end
        else
          text "　　　　　　　　　　　　　　　　　　　　 #{arr[3]}", size: 16,styles: :bold
        end

        move_down 10
        text "￥　#{arr[4]} -", size: 16,styles: :bold, :align => :center
        line [140, 110], [400, 110]
        stroke
        move_down 15
        if arr[5].present?
          text "但し、#{arr[5]}、上記正に領収いたしました。", size: 11, :align => :center
        else
          text "但し、お弁当代として、上記正に領収いたしました。", size: 11, :align => :center
        end

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
      image 'app/assets/images/taberu_stamp.png', at: [440, 585], width: 60 if stamp == "true"
      bounding_box([330, 595], :width => 200, :height => 70) do
        move_down 10
        text "タベル株式会社", size: 11
        text "〒150-0043", size: 11
        text "東京都渋谷区道玄坂2-10-12", size: 11
        text "新大宗ビル3号館9階", size: 11
        text "TEL：03-5539-6000", size: 11
      end
    end
  end


  def sen
    stroke_axis
  end
end
