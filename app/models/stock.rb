class Stock < ApplicationRecord
  has_many :stock_materials, dependent: :destroy
  has_many :materials, through: :stock_materials
  accepts_nested_attributes_for :stock_materials, allow_destroy: true
end
