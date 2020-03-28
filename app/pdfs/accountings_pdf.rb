class AccountingsPdf < Prawn::Document
  def initialize(presigned_url)
    super(
      page_size: 'A4',
      :top_margin    => 0 )
    #日本語のフォント
    font "vendor/assets/fonts/ipaexg.ttf"
    n=1
    presigned_url.each do |id,url|
      body(url)
      if n < presigned_url.length
        start_new_page
        n += 1
      end
    end

  end

  def body(url)
    move_down 10
    image open(url), at: [-50, 750], width: 620
    image 'app/assets/images/taberu_stamp.png', at: [440, 630], width: 60



  end


  def sen
    stroke_axis
  end
end
