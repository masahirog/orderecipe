class Order < ApplicationRecord
  paginates_per 20

  has_many :order_materials, dependent: :destroy
  has_many :materials, through: :order_materials
  accepts_nested_attributes_for :order_materials, reject_if: :reject_material_blank, allow_destroy: true

  has_many :order_products, dependent: :destroy
  has_many :products, through: :order_products
  accepts_nested_attributes_for :order_products, allow_destroy: true, update_only: true

  before_save :initialize_inventory_calculation
  #納品量の初期化
  after_save :input_inventory_calculation
  #納品量の追加

  def initialize_inventory_calculation
    new_inventory_calculations = []
    update_inventory_calculations = []
    dates = self.order_materials.map{|om|om.delivery_date_was}.uniq
    order_materials_group = OrderMaterial.joins(:order).where(:orders => {fixed_flag:true}).where(delivery_date:dates).group('delivery_date').group('material_id').sum(:order_quantity)
    order_materials_group.each do |omg|
      date = omg[0][0]
      material_id = omg[0][1]
      inventory_calculation = InventoryCalculation.find_by(date:date,material_id:material_id)
      if inventory_calculation
        inventory_calculation.delivery_amount = 0
        update_inventory_calculations << inventory_calculation
      else
        new_inventory_calculations << InventoryCalculation.new(material_id:material_id,date:date,delivery_amount:0)
      end
    end
    InventoryCalculation.import new_inventory_calculations if new_inventory_calculations.present?
    InventoryCalculation.import update_inventory_calculations, on_duplicate_key_update:[:delivery_amount] if update_inventory_calculations.present?
  end


  def input_inventory_calculation
    new_inventory_calculations = []
    update_inventory_calculations = []
    dates = self.order_materials.map{|om|om.delivery_date}.uniq
    order_materials_group = OrderMaterial.joins(:order).where(:orders => {fixed_flag:true}).where(delivery_date:dates).group('delivery_date').group('material_id').sum(:order_quantity)
    self.order_materials.each do |om|
      inventory_calculation = InventoryCalculation.find_by(date:om.delivery_date,material_id:om.material_id)
      if inventory_calculation
        inventory_calculation.delivery_amount = order_materials_group[[om.delivery_date,om.material_id]].to_f
        update_inventory_calculations << inventory_calculation
      else
        new_inventory_calculations << InventoryCalculation.new(material_id:om.material_id,date:om.delivery_date,delivery_amount:order_materials_group[[om.delivery_date,om.material_id]].to_f)
      end
    end
    InventoryCalculation.import new_inventory_calculations if new_inventory_calculations.present?
    InventoryCalculation.import update_inventory_calculations, on_duplicate_key_update:[:delivery_amount] if update_inventory_calculations.present?
  end

  def reject_material_blank(attributes)
    attributes.merge!(_destroy: "1") if attributes[:material_id].blank?
  end
end
