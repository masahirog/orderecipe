class OrderMaterial < ApplicationRecord
  belongs_to :order
  belongs_to :material

  validates :order_quantity, presence: true, format: { :with=>/\A\d+(\.)?+(\d){0,1}\z/,
    message: "：小数点1位までの値が入力できます" }
  validates :material_id, presence: true
end
