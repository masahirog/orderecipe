class CookingRice < ApplicationRecord
  enum base_rice: {白米:1, マンナン:2}
  has_many :products
end
