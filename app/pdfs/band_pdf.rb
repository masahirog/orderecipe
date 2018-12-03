class BandPdf < Prawn::Document
  def initialize(product)
    # 初期設定。ここでは用紙のサイズを指定している。
    super(
      page_size: 'A4',
      page_layout: :landscape,
      :top_margin    => 0 )
    #日本語のフォント
    font "vendor/assets/fonts/ipaexm.ttf"
    header(product,17)
    header(product,22)

  end

  def header(product,y)
    move_down y
    font "vendor/assets/fonts/AozoraMinchoMedium.ttf"
    image "#{Rails.root}/app/assets/images/logo_daily.png", :width => 64, :position => :center
    move_down 20
    text "#{product.name}", size: 20, :align => :center,styles: :bold
    move_down 20
    text "#{product.menus[3].food_label_name}", size: 9, :align => :center
    move_down 9
    text "#{product.menus[4].food_label_name}", size: 9, :align => :center
    move_down 20
    font "vendor/assets/fonts/mplus-1p-regular.ttf"
    text "#{FoodIngredient.make_obi_nutrition(product.menus.ids)}", size: 6, :align => :center
    move_down 12
    text "カロリー #{MenuMaterial.where(menu_id:product.menus.ids).sum(:calorie).round()} kcal", size: 6, :align => :center
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
