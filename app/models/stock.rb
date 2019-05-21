class Stock < ApplicationRecord
  has_many :stock_materials, dependent: :destroy
  has_many :materials, through: :stock_materials
  accepts_nested_attributes_for :stock_materials, allow_destroy: true

  after_save :input_inventory_calculation

  def input_inventory_calculation
    date = self.date
    existing_inventory_calculations = InventoryCalculation.where(date:date).map { |inventory_calculation| [inventory_calculation.material_id, inventory_calculation] }.to_h
    new_inventory_calculations = []
    update_inventory_calculations = []
    self.stock_materials.each do |sm|
      if existing_inventory_calculations[sm.material_id]
        inventory_calculation = existing_inventory_calculations[sm.material_id]
        inventory_calculation.end_stock = sm.amount
        update_inventory_calculations << inventory_calculation
      else
        new_inventory_calculations << InventoryCalculation.new(material_id:sm.material_id,date:date,end_stock:sm.amount)
      end
    end
    InventoryCalculation.import new_inventory_calculations if new_inventory_calculations.present?
    InventoryCalculation.import update_inventory_calculations, on_duplicate_key_update:[:end_stock] if update_inventory_calculations.present?
  end
end
