class MasuOrder < ApplicationRecord
  has_many :masu_order_details, dependent: :destroy
  accepts_nested_attributes_for :masu_order_details, allow_destroy: true

  validates :kurumesi_order_id, presence: true, uniqueness: true

  enum payment: {請求書:0, 現金:1, クレジットカード:2}
  enum miso: {なし:0, あり:1}
  enum tea: {不要:0, PET:1, 缶:2}

  after_save :input_inventory_calculation
  after_destroy :input_inventory_calculation

  def input_inventory_calculation
    date = self.start_time
    inventory_calculations = InventoryCalculation.where(date:date)
    inventory_calculations.update_all(used_amount:0)

    new_inventory_calculations = []
    update_inventory_calculations = []

    shogun_order_products = DailyMenuDetail.joins(:daily_menu).where(:daily_menus => {start_time:date,fixed_flag:true}).group('product_id').sum(:manufacturing_number).to_a
    masu_order_details = MasuOrderDetail.joins(:masu_order).where(:masu_orders => {start_time:date})
    masu_order_products = masu_order_details.map{|mod|[mod.product_id,mod.number]}


    product_manufacturing = masu_order_products + shogun_order_products
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
  end
end
