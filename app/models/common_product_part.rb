class CommonProductPart < ApplicationRecord
	has_many :product_parts
	enum container: {ビニル袋:0, 真空パック:1,タッパー:2,バット:3,カップ:4,パック（シーラー）:5}
	enum loading_container: {青コンテナ:0,黒コンテナ:1,冷凍:2}
	enum loading_position: {積載:0,切出:1,調理場:2}
	after_update :update_product_parts

	def view_name_and_product_name
		if self.product_name.present?
			self.name + " 【 " + self.product_name + " 】"
		else
			self.name + " 【 - 】"
		end
	end
	
	def update_product_parts
	    update_pps = []
	    self.product_parts.each do |pp|
	    	pp.name = self.name
	    	pp.unit = self.unit
	    	pp.memo = self.memo
	    	pp.container = self.container
	    	pp.loading_container = self.loading_container
	    	pp.loading_position = self.loading_position
	    	update_pps << pp
    	end
    	ProductPart.import update_pps, on_duplicate_key_update:[:name,:unit,:memo,:container,:loading_container,:loading_position]
  	end
end
