class RiceSheet < Prawn::Document
  def initialize(hash,date,shogun_mazekomi,kurumesi_mazekomi)
    # 初期設定。ここでは用紙のサイズを指定している。
    super(
      page_size: 'A4',
      page_layout: :landscape)
    #日本語のフォント
    font "vendor/assets/fonts/ipaexm.ttf"
    text "#{DateTime.parse(date).strftime("%m月 %d日")}の炊飯シート",size:12
    text "発行時間：#{Time.now.strftime("%m月 %d日　%H:%M")}",size:10,:align=>:right
    table_content_a(hash)
    start_new_page
    text "#{DateTime.parse(date).strftime("%m月 %d日")} 混ぜ込み系",size:12
    text "発行時間：#{Time.now.strftime("%m月 %d日　%H:%M")}",size:10,:align=>:right
    table_content_b(shogun_mazekomi,kurumesi_mazekomi)
  end
  def table_content_a(hash)
    bounding_box([0, 500], :width => 780) do
      table line_item_rows_a(hash) do
        grayout = []
        cells.size = 10
        cells.padding = 3
        cells.borders = [:bottom]
        cells.border_width = 0.2
        row(0).border_width = 1
        self.header = true
        self.column_widths = [40,150,80,60,60,220,170]
        values = cells.columns(-1).rows(1..-1)
        values.each do |cell|
          grayout << cell.row unless cell.content == ""
        end
        grayout.map{|num|row(num).column(0..-1).background_color = "dcdcdc"}
        columns(3..4).size = 13
        columns(-1).size = 8
        row(0).size = 10
      end
    end
  end
  def line_item_rows_a(hash)
    ar = []
    n = 1
    data= [['No.','名前','盛りグラム','炊飯升','食数','備考','弁当名']]
    hash.each do |suihan|
      cooking_rice = suihan[1][:cooking_rice]
      kurikoshi = suihan[1][:kurikoshi]
      kurikosu = suihan[1][:kurikosu]
      kurikosu_kg = suihan[1][:kurikosu_kg]
      kurikoshi_kg = suihan[1][:kurikoshi_kg]
      suihan[1][:amount].each_with_index do |amount,i|
        if i == 0
          if kurikoshi > 0
            if suihan[1][:amount].length > 1
              data << [">>",cooking_rice.name,"#{cooking_rice.serving_amount} g",amount[0],amount[1],"繰越し#{kurikoshi_kg}kg使用","#{suihan[1][:product_name]}  #{suihan[1][:make_num]}食"]
            else
              data << [">>",cooking_rice.name,"#{cooking_rice.serving_amount} g",amount[0],amount[1],"繰越しの#{(kurikoshi_kg - kurikosu_kg).floor(1)}kg使用、#{kurikosu_kg}kg繰越し","#{suihan[1][:product_name]}  #{suihan[1][:make_num]}食"]
            end
            n -= 1
          else
            data << [n,cooking_rice.name,"#{cooking_rice.serving_amount} g",amount[0],amount[1],'',"#{suihan[1][:product_name]} #{suihan[1][:make_num]}食"]
          end
        elsif i == suihan[1][:amount].length - 1 && kurikosu > 0
          data << [n,cooking_rice.name,"#{cooking_rice.serving_amount} g",amount[0],amount[1],"#{kurikosu_kg}kg繰越し",'']
        else
          data << [n,cooking_rice.name,"#{cooking_rice.serving_amount} g",amount[0],amount[1],'','']
        end
        n += 1
      end
    end
    data
  end

  def table_content_b(shogun_mazekomi,kurumesi_mazekomi)
    table line_item_rows_b(shogun_mazekomi,kurumesi_mazekomi) do
      cells.size = 10
      cells.padding = 3
      cells.borders = [:bottom]
      cells.border_width = 0.2
      self.header = true
      self.column_widths = [280,50,180,50,100]
    end
  end
  def line_item_rows_b(shogun_mazekomi,kurumesi_mazekomi)
    ar = []
    n = 1
    data = [['弁当名','食数','食材名',"1食分",'製造数分量']]
    shogun_mazekomi.each do |sm|
      product = Product.find(sm[0])
      sm[1].each do |m|
        data << [product.name,m[1],m[0],"#{m[3]}#{m[5]}","#{m[4]}#{m[5]}"]
      end
    end
    kurumesi_mazekomi.each do |km|
      brand = Brand.find(km[0])
      km[1].each do |m|
        data << [brand.name,m[1][1],m[1][0],"#{m[1][3]}#{m[1][5]}","#{m[1][4]}#{m[1][5]}"]
      end
    end
    data
  end




  def sen
    stroke_axis
  end
end
