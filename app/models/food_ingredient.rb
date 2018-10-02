# 単位
# calorie kcal/100g
# protein g/100g
# lipid g/100g
# carbohydrate g/100g
# dietary_fiber g/100g
# potassium mg/100g
# calcium mg/100g
# vitamin_b1 mg/100g
# vitamin_b2 mg/100g
# vitamin_c mg/100g
# salt g/100g

class FoodIngredient < ApplicationRecord
  has_many :menu_materials
  scope :food_ingredient_search, lambda { |query| where('name LIKE ?', "%#{query}%").limit(100) }

  def self.calculate_nutrition(gram_amount,id)
    food_ingredient = self.find(id)
    calorie = (gram_amount * food_ingredient.calorie / 100).round(2)
    protein = (gram_amount * food_ingredient.protein / 100).round(2)
    lipid = (gram_amount * food_ingredient.lipid / 100).round(2)
    carbohydrate = (gram_amount * food_ingredient.carbohydrate / 100).round(2)
    dietary_fiber = (gram_amount * food_ingredient.dietary_fiber / 100).round(2)
    potassium = (gram_amount * food_ingredient.potassium / 100).round(2)
    calcium = (gram_amount * food_ingredient.calcium / 100).round(2)
    vitamin_b1 = (gram_amount * food_ingredient.vitamin_b1 / 100).round(2)
    vitamin_b2 = (gram_amount * food_ingredient.vitamin_b2 / 100).round(2)
    vitamin_c = (gram_amount * food_ingredient.vitamin_c / 100).round(2)
    salt = (gram_amount * food_ingredient.salt / 100).round(2)
    magnesium = (gram_amount * food_ingredient.magnesium / 100).round(2)
    iron = (gram_amount * food_ingredient.iron / 100).round(2)
    zinc = (gram_amount * food_ingredient.zinc / 100).round(2)
    copper = (gram_amount * food_ingredient.copper / 100).round(2)
    folic_acid = (gram_amount * food_ingredient.folic_acid / 100).round(2)
    vitamin_d = (gram_amount * food_ingredient.vitamin_d / 100).round(2)
    @html = "カロリー：#{calorie}kcal"
    @menu_material_food_ingredient = {calorie:calorie,protein:protein,lipid:lipid,
      carbohydrate:carbohydrate,dietary_fiber:dietary_fiber,potassium:potassium,calcium:calcium,
      vitamin_b1:vitamin_b1,vitamin_b2:vitamin_b2,vitamin_c:vitamin_c,salt:salt,magnesium:magnesium,
      iron:iron,zinc:zinc,copper:copper,folic_acid:folic_acid,vitamin_d:vitamin_d}
    return [@menu_material_food_ingredient,@html]
  end


  def self.cehck_nutrition(product)
    menu_materials = MenuMaterial.where(menu_id:product.menus.ids )
    material_ids = MenuMaterial.where(menu_id:product.menus.ids ).map(&:material_id).uniq
    vegetable_ids = Material.where(id:material_ids,vegetable_flag:1).map(&:id)
    vegetable = MenuMaterial.where(material_id:vegetable_ids ).sum(:gram_quantity).round(2)
    calorie = menu_materials.sum(:calorie).round(2)
    protein = menu_materials.sum(:protein).round(2)
    lipid = menu_materials.sum(:lipid).round(2)
    carbohydrate = menu_materials.sum(:carbohydrate).round(2)
    dietary_fiber = menu_materials.sum(:dietary_fiber).round(2)
    potassium = menu_materials.sum(:potassium).round(2)
    calcium = menu_materials.sum(:calcium).round(2)
    vitamin_b1 = menu_materials.sum(:vitamin_b1).round(2)
    vitamin_b2 = menu_materials.sum(:vitamin_b2).round(2)
    vitamin_c = menu_materials.sum(:vitamin_c).round(2)
    salt = menu_materials.sum(:salt).round(2)
    magnesium = menu_materials.sum(:magnesium).round(2)
    iron = menu_materials.sum(:iron).round(2)
    zinc = menu_materials.sum(:zinc).round(2)
    copper = menu_materials.sum(:copper).round(2)
    folic_acid = menu_materials.sum(:folic_acid).round(2)
    vitamin_d = menu_materials.sum(:vitamin_d).round(2)
    nutritions = []
    # 基準
    nutritions << '野菜多め' if vegetable >= 116.7
    nutritions << 'たんぱく質' if protein >= 16.7
    nutritions << '食物繊維' if dietary_fiber >= 6.7
    sugar = carbohydrate - dietary_fiber
    nutritions << 'カリウム' if potassium >= 833.3
    nutritions << 'カルシウム' if calcium >= 200.0
    nutritions << 'ビタミンB1' if vitamin_b1 >= 0.4
    nutritions << 'ビタミンB2' if vitamin_b2 >= 0.4
    nutritions << 'ビタミンC' if vitamin_c >= 28.3
    nutritions << 'ビタミンD' if vitamin_d >= 1.8
    nutritions << 'マグネシウム' if magnesium >= 98.3
    nutritions << '鉄' if iron >= 2.1
    nutritions << '亜鉛' if zinc >= 2.7
    nutritions << '銅' if copper >= 0.2
    nutritions << '葉酸' if folic_acid >= 66.7
    nutritions << '脂質控えめ' if lipid <= 25.6
    nutritions << '糖質控えめ' if sugar <= 117.9
    nutritions << '塩分控えめ' if salt <= 2.7
    @nutritions=''
    nutritions.each_with_index do |nutrition,i|
      if i ==0
        @nutritions += "#{nutrition} "
      else
        @nutritions += "＋ #{nutrition} "
      end
    end
    return @nutritions
  end

  def self.make_obi_nutrition(menus)
    menu_materials = MenuMaterial.where(menu_id:menus )
    material_ids = MenuMaterial.where(menu_id:menus ).map(&:material_id).uniq
    vegetable_ids = Material.where(id:material_ids,vegetable_flag:1).map(&:id)
    vegetable = MenuMaterial.where(material_id:vegetable_ids ).sum(:gram_quantity).round(2)
    calorie = menu_materials.sum(:calorie).round(2)
    protein = menu_materials.sum(:protein).round(2)
    lipid = menu_materials.sum(:lipid).round(2)
    carbohydrate = menu_materials.sum(:carbohydrate).round(2)
    dietary_fiber = menu_materials.sum(:dietary_fiber).round(2)
    potassium = menu_materials.sum(:potassium).round(2)
    calcium = menu_materials.sum(:calcium).round(2)
    vitamin_b1 = menu_materials.sum(:vitamin_b1).round(2)
    vitamin_b2 = menu_materials.sum(:vitamin_b2).round(2)
    vitamin_c = menu_materials.sum(:vitamin_c).round(2)
    salt = menu_materials.sum(:salt).round(2)
    magnesium = menu_materials.sum(:magnesium).round(2)
    iron = menu_materials.sum(:iron).round(2)
    zinc = menu_materials.sum(:zinc).round(2)
    copper = menu_materials.sum(:copper).round(2)
    folic_acid = menu_materials.sum(:folic_acid).round(2)
    vitamin_d = menu_materials.sum(:vitamin_d).round(2)
    nutritions = []
    # 基準
    nutritions << '野菜多め' if vegetable >= 116.7
    nutritions << 'たんぱく質' if protein >= 16.7
    nutritions << '食物繊維' if dietary_fiber >= 6.7
    sugar = carbohydrate - dietary_fiber
    nutritions << 'カリウム' if potassium >= 833.3
    nutritions << 'カルシウム' if calcium >= 200.0
    nutritions << 'ビタミンB1' if vitamin_b1 >= 0.4
    nutritions << 'ビタミンB2'if vitamin_b2 >= 0.4
    nutritions << 'ビタミンC'if vitamin_c >= 28.3
    nutritions << 'ビタミンD' if vitamin_d >= 1.8
    nutritions << 'マグネシウム' if magnesium >= 98.3
    nutritions << '鉄' if iron >= 2.1
    nutritions << '亜鉛' if zinc >= 2.7
    nutritions << '銅' if copper >= 0.2
    nutritions << '葉酸' if folic_acid >= 66.7
    nutritions << '脂質控えめ' if lipid <= 25.6
    nutritions << '糖質控えめ' if sugar <= 117.9
    nutritions << '塩分控えめ'if salt <= 2.7
    @nutritions=''
    nutritions.each_with_index do |nutrition,i|
      if i ==0
        @nutritions += "#{nutrition} "
      else
        @nutritions += "＋ #{nutrition} "
      end
    end
    return @nutritions
  end
end
