class Brand < ApplicationRecord
  belongs_to :group
  has_many :products
  has_many :reviews
end
