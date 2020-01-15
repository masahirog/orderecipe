class ProductPdfAllRoma < Prawn::Document
  def initialize(id,controller)
    super(
      page_size: 'A4',
      page_layout: :landscape,
      margin:10
    )
    font "vendor/assets/fonts/ipaexg.ttf"
    daily_menu = DailyMenu.find(id)
    max_i = daily_menu.daily_menu_details.length
    date = daily_menu.start_time
    daily_menu.daily_menu_details.each_with_index do |dmd,i|
      product = dmd.product
      menus = product.menus
      num = dmd.manufacturing_number
      kanji(product,menus,num)
      header_table(product,num,date)
      table_content(menus,num)
      start_new_page if i<max_i-1
    end
  end



  def header_table(product,num,date)
    bounding_box([0, 570], :width => 830) do
      data = [["date","management_id","BentoMei","Kategori","Genka","Seizosu"],
              [date,"#{product.management_id}","#{product.name}","#{product.cook_category}","#{product.cost_price} en","#{num}ninbun"]]
      table data, cell_style: { size: 9 } do
        cells.padding = 2
        row(0).background_color = 'dcdcdc'
        row(0).borders = [:bottom]
        columns(0..5).borders = []
        row(0).columns(0..5).borders = [:bottom]
        cells.border_width = 0.2
        cells.height = 14
        self.header = true
        self.column_widths = [100,100,330,100,100,100]
      end
    end
  end

  def table_content(menus,num)
    bounding_box([0, 540], :width => 830) do
      table line_item_rows(menus,num) do
      cells.padding = 3
      cells.size = 9
      cells.borders = [:bottom]
      cells.border_width = 0.1
      cells.border_color = "a9a9a9"
      column(3).align = :right
      column(4).size = 9
      column(4).align = :center
      column(4).text_color = '808080'
      row(0).border_width = 1
      row(0).border_color = "000000"
      row(0).background_color = 'dcdcdc'
      row(0).text_color = "000000"
      # column(4).background_color = 'dcdcdc'
      column(3).padding = [3,8,3,3]
      row(0).size = 9
      self.header = true
      self.column_widths = [130,150,150,80,30,60,230]

      end
    end
  end
  def line_item_rows(menus,num)
    data= [["Menu Mei","Chori Memo","Shokuzai","#{num}nin-bun",'✓',{:content => "Shikomi", :colspan => 2}]]
    menus.each do |menu|
      unless menu.category == '容器'
        u = menu.materials.length
        cook_the_day_before_mozi = menu.cook_the_day_before.length
        if cook_the_day_before_mozi<50
          cook_the_day_before_size = 10
        elsif cook_the_day_before_mozi<100
          cook_the_day_before_size = 9
        elsif cook_the_day_before_mozi<150
          cook_the_day_before_size = 8
        else
          cook_the_day_before_size = 7
        end
        menu.menu_materials.each_with_index do |mm,i|
          if mm.post.present?
            check = "□"
          else
            check = ""
          end
          if i == 0
            data << [{content: "#{menu.name}", rowspan: u},
              {content: "【zenzitsu】\n#{menu.cook_the_day_before}\n‐・‐・‐・‐・‐・‐・‐\n【touzitsu】\n#{menu.cook_on_the_day}", rowspan: u, size: cook_the_day_before_size},"#{mm.material.name}",
              "#{((mm.amount_used * num.to_i).round).to_s(:delimited)} #{mm.material.recipe_unit}",check,mm.post,mm.preparation]
          else
            data << [mm.material.name,{content:"#{((mm.amount_used * num.to_i).round).to_s(:delimited)} #{mm.material.recipe_unit}"},
              check,mm.post,mm.preparation]
          end
        end
      end
    end
    data
  end


  def kanji(product,menus,num)
    kana_cook_the_day_befores = ""
    kana_cook_on_the_days = ""
    kana_posts = ""
    kana_preparations = ""
    kana_product_name = ""
    kana_menu_names = ''
    kana_material_names = ""
    menu_names = ""
    cook_the_day_befores = ""
    cook_on_the_days = ""
    material_names = ""
    posts = ""
    preparations = ""
    menus.each do |menu|
      menu_names += menu.name + "^^"
      cook_the_day_befores += menu.cook_the_day_before + "^^"
      cook_on_the_days += menu.cook_on_the_day + "^^"
      menu.menu_materials.each do |mmm|
        material_names += mmm.material.name + "^^"
        posts += mmm.post + "^^"
        preparations += mmm.preparation + "^^"
      end
    end
    kana_product_name = Product.make_katakana(product.name)[0]
    kana_menu_names = Product.make_katakana(menu_names)
    kana_material_names = Product.make_katakana(material_names)
    kana_cook_the_day_befores = Product.make_katakana(cook_the_day_befores)
    kana_cook_on_the_days = Product.make_katakana(cook_on_the_days)
    kana_posts = Product.make_katakana(posts)
    kana_preparations = Product.make_katakana(preparations)
    product.name = Romaji.kana2romaji kana_product_name
    ii=0
    menus.each_with_index do |menu,i|
      menu.name = Romaji.kana2romaji kana_menu_names[i]
      menu.cook_the_day_before = Romaji.kana2romaji kana_cook_the_day_befores[i]
      menu.cook_on_the_day = Romaji.kana2romaji kana_cook_on_the_days[i]
      menu.menu_materials.each do |mmm|
        mmm.material.name = Romaji.kana2romaji kana_material_names[ii]
        mmm.post = Romaji.kana2romaji kana_posts[ii]
        mmm.preparation = Romaji.kana2romaji kana_preparations[ii]
        ii += 1
      end
    end
  end

  def sen
    stroke_axis
  end


end
