class Order < ApplicationRecord
  paginates_per 10

  has_many :order_materials, dependent: :destroy
  has_many :materials, through: :order_materials
  accepts_nested_attributes_for :order_materials, reject_if: :reject_material_blank, allow_destroy: true

  has_many :order_products, dependent: :destroy
  has_many :products, through: :order_products
  accepts_nested_attributes_for :order_products, allow_destroy: true, update_only: true


  def reject_material_blank(attributes)
    attributes.merge!(_destroy: "1") if attributes[:material_id].blank?
  end
end
