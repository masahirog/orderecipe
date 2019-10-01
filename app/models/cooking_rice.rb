class CookingRice < ApplicationRecord
  enum base_rice: {白米:1, マンナン:2}
  has_many :products
  has_many :cooking_rice_materials, dependent: :destroy
  accepts_nested_attributes_for :cooking_rice_materials, allow_destroy: true
end
