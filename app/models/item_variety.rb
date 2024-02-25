class ItemVariety < ApplicationRecord
	belongs_to :item
	belongs_to :item_type
	def view_variety_and_type
		self.item_type.name + " " + self.name
	end
end
