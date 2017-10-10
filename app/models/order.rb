class Order < ApplicationRecord
  paginates_per 10

  has_many :order_materials, dependent: :destroy
  has_many :materials, through: :order_materials
  accepts_nested_attributes_for :order_materials, allow_destroy: true, update_only: true



  # def self.search(params)
  #   if params
  #     from = params[:from]
  #     to = params[:to]
  #     data = Order.all
  #
  #     if from.present? && to.present?
  #       data = data.where(delivery_date: from..to)
  #     elsif from.present?
  #       data = data.where('delivery_date >= ?', from)
  #       elsif to.present?
  #       data = data.where('delivery_date <= ?', to)
  #     end
  #
  #   else
  #     Order.all
  #   end
  # end
end
