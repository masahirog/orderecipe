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
    @html = "カロリー：#{calorie}kcal"
    @menu_material_food_ingredient = {calorie:calorie,protein:protein,lipid:lipid,
      carbohydrate:carbohydrate,dietary_fiber:dietary_fiber,potassium:potassium,calcium:calcium,
      vitamin_b1:vitamin_b1,vitamin_b2:vitamin_b2,vitamin_c:vitamin_c,salt:salt}
    return [@menu_material_food_ingredient,@html]
  end


  def self.cehck_nutrition(product)
    menu_materials = MenuMaterial.where(menu_id:product.menus.ids )
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
    nutritions = []
    # 基準
    nutritions << 'たんぱく質' if protein >= 16.7
    nutritions << '食物繊維' if dietary_fiber >= 6.7
    sugar = carbohydrate - dietary_fiber
    nutritions << 'カリウム' if potassium >= 833.3
    nutritions << 'カルシウム' if calcium >= 200.0
    nutritions << 'ビタミンB1' if vitamin_b1 >= 0.4
    nutritions << 'ビタミンB2'if vitamin_b2 >= 0.4
    nutritions << 'ビタミンC'if vitamin_c >= 28.3
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

  def self.make_obi_nutrition(menus)
    menu_materials = MenuMaterial.where(menu_id:menus )
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
    nutritions = []
    # 基準
    nutritions << 'たんぱく質' if protein >= 16.7
    nutritions << '食物繊維' if dietary_fiber >= 6.7
    sugar = carbohydrate - dietary_fiber
    nutritions << 'カリウム' if potassium >= 833.3
    nutritions << 'カルシウム' if calcium >= 200.0
    nutritions << 'ビタミンB1' if vitamin_b1 >= 0.4
    nutritions << 'ビタミンB2'if vitamin_b2 >= 0.4
    nutritions << 'ビタミンC'if vitamin_c >= 28.3
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
