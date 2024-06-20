# 単位 1gあたりで登録
class FoodIngredient < ApplicationRecord
  has_many :materials
  scope :food_ingredient_search, lambda { |query| where('name LIKE ?', "%#{query}%").limit(100) }

  def self.calculate_nutrition(gram_amount,id)
    food_ingredient = self.find(id)
    calorie = (gram_amount * food_ingredient.calorie / 100).round(2)
    protein = (gram_amount * food_ingredient.protein / 100).round(2)
    lipid = (gram_amount * food_ingredient.lipid / 100).round(2)
    carbohydrate = (gram_amount * food_ingredient.carbohydrate / 100).round(2)
    dietary_fiber = (gram_amount * food_ingredient.dietary_fiber / 100).round(2)
    salt = (gram_amount * food_ingredient.salt / 100).round(2)
    @html = "カロリー：#{calorie}kcal"
    @menu_material_food_ingredient = {calorie:calorie,protein:protein,lipid:lipid,
      carbohydrate:carbohydrate,dietary_fiber:dietary_fiber,salt:salt}
    return [@menu_material_food_ingredient,@html]
  end
end
