class Order < ApplicationRecord
  paginates_per 20

  has_many :order_materials, dependent: :destroy
  has_many :materials, through: :order_materials
  accepts_nested_attributes_for :order_materials, reject_if: :reject_material_blank, allow_destroy: true

  has_many :order_products, dependent: :destroy
  has_many :products, through: :order_products
  accepts_nested_attributes_for :order_products, allow_destroy: true, update_only: true

  before_save :initialize_stock
  #納品量の追加
  after_save :input_stock

  def initialize_stock
    if self.fixed_flag == true
      before_dates = self.order_materials.map{|om|om.delivery_date_was}.uniq
      after_dates = self.order_materials.map{|om|om.delivery_date_was}.uniq
      @dates = (before_dates + after_dates).uniq
      stocks = Stock.where(date:@dates)
      stocks.update_all(delivery_amount:0)
    end
  end


  def input_stock
    if self.fixed_flag == true
      new_stocks = []
      update_stocks = []
      order_materials_group = OrderMaterial.joins(:order).where(:orders => {fixed_flag:true}).where(delivery_date:@dates).group('delivery_date').group('material_id').sum(:order_quantity)
      self.order_materials.each do |om|
        stock = Stock.find_by(date:om.delivery_date,material_id:om.material_id)
        if stock
          stock.delivery_amount = order_materials_group[[om.delivery_date,om.material_id]].to_f
          update_stocks << stock
        else
          new_stocks << Stock.new(material_id:om.material_id,date:om.delivery_date,delivery_amount:order_materials_group[[om.delivery_date,om.material_id]].to_f)
        end
      end

      Stock.import new_stocks if new_stocks.present?
      Stock.import update_stocks, on_duplicate_key_update:[:delivery_amount] if update_stocks.present?
    end
  end

  def reject_material_blank(attributes)
    attributes.merge!(_destroy: "1") if attributes[:material_id].blank?
  end
end
