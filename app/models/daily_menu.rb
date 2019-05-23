class DailyMenu < ApplicationRecord
  has_many :daily_menu_details, ->{order("row_order") }, dependent: :destroy
  accepts_nested_attributes_for :daily_menu_details, allow_destroy: true

  after_save :input_stock
  #納品量の追加

  def input_stock
    date = self.start_time
    stocks = Stock.where(date:date)
    stocks.update_all(used_amount:0)

    new_stocks = []
    update_stocks = []
    masu_order_products = MasuOrderDetail.joins(:masu_order).where(:masu_orders => {start_time:date,fixed_flag:true}).group('product_id').sum(:number).to_a
    shogun_order_products = DailyMenuDetail.joins(:daily_menu).where(:daily_menus => {start_time:date,fixed_flag:true}).group('product_id').sum(:manufacturing_number).to_a
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
      stock = Stock.find_by(date:date,material_id:data[0])
      if stock
        stock.used_amount = used_amount
        update_stocks << stock
      else
        new_stocks << Stock.new(material_id:data[0],date:date,used_amount:used_amount)
      end
    end
    Stock.import new_stocks if new_stocks.present?
    Stock.import update_stocks, on_duplicate_key_update:[:used_amount] if update_stocks.present?
    # Stock.calculate_stock(date,hash)
  end
end
