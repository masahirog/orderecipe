class DailyMenu < ApplicationRecord
  has_many :daily_menu_details, ->{order("row_order") }, dependent: :destroy
  accepts_nested_attributes_for :daily_menu_details, allow_destroy: true

  after_save :input_inventory_calculation
  #納品量の追加

  def input_inventory_calculation
    new_inventory_calculations = []
    update_inventory_calculations = []

    date = self.start_time
    inventory_calculations = InventoryCalculation.where(date:date)
    inventory_calculations.update_all(used_amount:0)

    new_inventory_calculations = []
    update_inventory_calculations = []

    masu_order_products = MasuOrderDetail.joins(:masu_order).where(:masu_orders => {start_time:date}).group('product_id').sum(:number).to_a
    if self.fixed_flag == true
      shogun_order_products = self.daily_menu_details.map{|dmd|[dmd.product_id,dmd.manufacturing_number]}
      product_manufacturing = masu_order_products + shogun_order_products
    else
      product_manufacturing = masu_order_products
    end
    hash = {}
    product_manufacturing.each do |pm|
      product = Product.find(pm[0])
      menu_ids = product.menus.ids
      menu_materials = MenuMaterial.where(menu_id:menu_ids)
      menu_materials.each do |mm|
        if hash[mm.material_id]
          hash[mm.material_id] += mm.amount_used * pm[1]
        else
          hash[mm.material_id] = mm.amount_used * pm[1]
        end
      end
    end
    hash.each do |data|
      material = Material.find(data[0])
      calculated_value = material.calculated_value.to_f
      order_unit_quantity = material.order_unit_quantity.to_f
      used_amount = (data[1] / calculated_value) * order_unit_quantity
      inventory_calculation = InventoryCalculation.find_by(date:date,material_id:data[0])
      if inventory_calculation
        inventory_calculation.used_amount = used_amount
        update_inventory_calculations << inventory_calculation
      else
        new_inventory_calculations << InventoryCalculation.new(material_id:data[0],date:date,used_amount:used_amount)
      end
    end
    InventoryCalculation.import new_inventory_calculations if new_inventory_calculations.present?
    InventoryCalculation.import update_inventory_calculations, on_duplicate_key_update:[:used_amount] if update_inventory_calculations.present?
    # InventoryCalculation.calculate_stock(date,hash)
  end
end
