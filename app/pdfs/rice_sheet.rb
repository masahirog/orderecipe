class RiceSheet < Prawn::Document
  def initialize(hash,date,shogun_mazekomi,kurumesi_mazekomi)
    # 初期設定。ここでは用紙のサイズを指定している。
    super(
      page_size: 'A4',
      page_layout: :portrait)
    #日本語のフォント
    font "vendor/assets/fonts/ipaexg.ttf"
    text "#{DateTime.parse(date).strftime("%m月 %d日")}の炊飯シート　　　　　　 　　　　　　　　　　　　　　　　#{Time.now.strftime("%m月 %d日　%H:%M")}"
    move_down 5
    table_content_a(hash)
    move_down 10
    table_content_b(shogun_mazekomi,kurumesi_mazekomi)
  end
  def table_content_a(hash)
    table line_item_rows_a(hash) do
      cells.size = 10
      cells.padding = 3
      cells.borders = [:bottom]
      cells.border_width = 0.2
      self.header = true
      self.column_widths = [40,70,100,300]
    end
  end
  def line_item_rows_a(hash)
    ar = []
    n = 1
    data= [['No.','名前','炊飯升(SHO)','備考(MEMO)']]
    hash.each do |suihan|
      name = suihan[1][:name]
      kurikoshi = suihan[1][:kurikoshi]
      kurikosu = suihan[1][:kurikosu]
      kurikosu_kg = suihan[1][:kurikosu_kg]
      kurikoshi_kg = suihan[1][:kurikoshi_kg]
      suihan[1][:amount].each_with_index do |amount,i|
        if i == 0
          data << [n,name,amount[0],"#{suihan[1][:product_name]} #{suihan[1][:make_num]}"]
        elsif i == suihan[1][:amount].length - 1 && kurikosu > 0
          data << [n,name,amount[0],"#{kurikosu_kg}kg Amari"]
        else
          data << [n,name,amount[0],'']
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
      columns(-1).align = :right
      self.header = true
      self.column_widths = [140,50,180,140]
    end
  end
  def line_item_rows_b(shogun_mazekomi,kurumesi_mazekomi)
    ar = []
    n = 1
    data = [['弁当名','食数','食材名','製造数分量']]
    shogun_mazekomi.each do |sm|
      product = Product.find(sm[0])
      sm[1].each do |m|
        data << [product.name,m[1],m[0],"#{m[4]}#{m[5]}"]
      end
    end
    kurumesi_mazekomi.each do |km|
      materials=[]
      menu = Menu.find(km[0])
      name = "#{menu.name}\n#{menu.roma_name}"
      km[1].each_with_index do |m,i|
        if i == 0
          data << [{:content => name, :rowspan => km[1].length },{:content => km[1].values[0][1].to_s, :rowspan => km[1].length },m[1][0],"#{m[1][2].to_s(:delimited)}#{m[1][3]}"]
        else
          data << [m[1][0],"#{m[1][2].to_s(:delimited)}#{m[1][3]}"]
        end
      end
    end
    data
  end

  def sen
    stroke_axis
  end
end
