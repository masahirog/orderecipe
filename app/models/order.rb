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
    before_dates = self.order_materials.map{|om|om.delivery_date_was}.uniq
    after_dates = self.order_materials.map{|om|om.delivery_date}.uniq
    @dates = (before_dates + after_dates).uniq
    stocks = Stock.where(date:@dates)
    stocks.update_all(delivery_amount:0)
  end


  def input_stock
    new_stocks = []
    update_stocks = []
    order_materials_group = OrderMaterial.where(un_order_flag:false).joins(:order).where(:orders => {fixed_flag:true}).where(delivery_date:@dates).group('delivery_date').group('material_id').sum(:order_quantity)
    order_materials_group.each do |omg|
      date = omg[0][0]
      material_id = omg[0][1]
      material = Material.find(material_id)
      #レシピ単位で計上する!
      # delivery_amount = omg[1].to_f * material.recipe_unit_quantity
      delivery_amount = omg[1].to_f
      stock = Stock.find_by(date:date,material_id:material_id)
      if stock
        stock.delivery_amount = delivery_amount
        end_day_stock = stock.start_day_stock - stock.used_amount + delivery_amount
        stock.end_day_stock = end_day_stock
        update_stocks << stock
        #未来の在庫を書き換えていく処理
        Stock.change_stock(update_stocks,material_id,date,end_day_stock)
      else
        end_day_stock = delivery_amount
        prev_stock = Stock.where("date < ?", date).where(material_id:material_id).order("date DESC").first
        if prev_stock.present?
          new_stocks << Stock.new(material_id:material_id,date:date,end_day_stock:end_day_stock,start_day_stock:prev_stock.end_day_stock)
        else
          new_stocks << Stock.new(material_id:material_id,date:date,end_day_stock:end_day_stock)
        end
        Stock.change_stock(update_stocks,material_id,date,end_day_stock)
      end
    end
    Stock.import new_stocks if new_stocks.present?
    Stock.import update_stocks, on_duplicate_key_update:[:delivery_amount,:end_day_stock,:start_day_stock] if update_stocks.present?
  end

  def reject_material_blank(attributes)
    attributes.merge!(_destroy: "1") if attributes[:material_id].blank?
  end
end
