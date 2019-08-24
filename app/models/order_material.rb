class OrderMaterial < ApplicationRecord
  attr_accessor :order_quantity_order_unit
  attr_accessor :order_unit
  attr_accessor :recipe_unit
  attr_accessor :recipe_unit_quantity
  attr_accessor :order_unit_quantity

  belongs_to :order
  belongs_to :material

  validates :order_quantity, numericality: true
  validates :order_quantity, presence: true, format: { :with=>/\A\d+(\.)?+(\d){0,1}\z/,
    message: "：小数点1位までの値が入力できます" }
  validates :material_id, presence: true
  validates :delivery_date, presence: true

  def attributes_with_virtual
    attributes.merge('start_time' => self.delivery_date)
  end
end
