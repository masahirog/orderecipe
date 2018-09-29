class BandPdf < Prawn::Document
  def initialize(bento_1,bento_2)
    # 初期設定。ここでは用紙のサイズを指定している。
    super(
      page_size: 'A4',
      page_layout: :landscape,
      :top_margin    => 0 )
    #日本語のフォント
    font "vendor/assets/fonts/ipaexm.ttf"
    [bento_1,bento_2].each_with_index do |bento,i|
      if i==0
        header(bento,17)
      else
        header(bento,22)
      end
    end

  end

  def header(bento,y)
    move_down y
    font "vendor/assets/fonts/AozoraMinchoMedium.ttf"
    image "#{Rails.root}/app/assets/images/logo_daily.png", :width => 64, :position => :center
    move_down 20
    text "#{bento[0]}", size: 20, :align => :center,styles: :bold
    move_down 20
    text "#{Menu.find(bento[1][2]).name}", size: 9, :align => :center
    move_down 9
    text "#{Menu.find(bento[1][3]).name}", size: 9, :align => :center
    move_down 20
    font "vendor/assets/fonts/mplus-1p-regular.ttf"
    text "#{FoodIngredient.make_obi_nutrition(bento[1])}", size: 6, :align => :center
    move_down 12
    text "カロリー #{MenuMaterial.where(menu_id:bento[1]).sum(:calorie).round()} kcal", size: 6, :align => :center
    move_down 24
    text "650円", size: 6, :align => :center
    move_down 30
    self.line_width = 0.5
    stroke_color "b5b5b5"
    stroke do
      horizontal_line -100, 900
    end
  end


  def sen
    stroke_axis
  end
end
