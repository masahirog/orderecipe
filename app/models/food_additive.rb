class FoodAdditive < ApplicationRecord
  has_many :materials, through: :material_food_additives
  has_many :material_food_additives
end
