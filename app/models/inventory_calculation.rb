class InventoryCalculation < ApplicationRecord
  def self.calculate_stock(date,hash)
    inventory_calculations = InventoryCalculation.where(date:date)
    hash.each do |material_used|
      material = Material.find(material_used[0])
      used = material_used[1]
      binding.pry
      ic = previous(date,material.id)
      if ic
        直帰の棚卸しを考慮するべし
      else
        そのまま引き算で在庫、未来には反映？

      end
    end
  end

  def self.previous(date,material_id)
    InventoryCalculation.where("date < ?", date).where(material_id:material_id).order("date DESC").first
  end

  def self.next(date,material_id)
    InventoryCalculation.where("date > ?", date).where(material_id:material_id).order("date ASC").first
  end
end
