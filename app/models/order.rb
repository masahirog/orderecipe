class Order < ApplicationRecord
  has_many :order_materials, dependent: :destroy
  has_many :materials, through: :order_materials
  accepts_nested_attributes_for :order_materials, allow_destroy: true, update_only: true
end
