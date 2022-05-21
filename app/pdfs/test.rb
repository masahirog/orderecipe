require 'barby/barcode/code_128'
require 'barby/outputter/png_outputter'

class Test < Prawn::Document
  def initialize(store_daily_menu)
    super(
      page_size: 'A4',
      :top_margin    => 0 )
    #日本語のフォント
    font "vendor/assets/fonts/ipaexg.ttf"
    body(store_daily_menu)
  end

  def body(store_daily_menu)
    image 'app/assets/images/taberu_stamp.png', at: [440, 630], width: 60
    barcode = Barby::Code128.new 417
    barcode_blob = Barby::PngOutputter.new(barcode).to_png
    barcode_io = StringIO.new(barcode_blob)
    barcode_io.rewind
    image barcode_io

  end


  def sen
    stroke_axis
  end
end
