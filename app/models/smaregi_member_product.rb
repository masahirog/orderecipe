class SmaregiMemberProduct < ApplicationRecord
	def self.calculate_number
		new_arr = []
		early_data =  SmaregiTradingHistory.where('date > ?', '2023-01-01').where('time < ?', '16:00').where(torihiki_meisaikubun:1,uchikeshi_torihiki_id:0).where.not(kaiin_id: nil).where.not(hinban:nil).group(:kaiin_id,:hinban).count
		SmaregiTradingHistory.where('date > ?', '2023-01-01').where(torihiki_meisaikubun:1,uchikeshi_torihiki_id:0)
		.where.not(kaiin_id: nil).where.not(hinban:nil).group(:kaiin_id,:hinban).count.each do |data|
			if early_data[[data[0][0],data[0][1]]].present?
				new_arr << SmaregiMemberProduct.new(kaiin_id:data[0][0],product_id:data[0][1],early_number_of_purchase:early_data[[data[0][0],data[0][1]]],total_number_of_purchase:data[1])
			else
				new_arr << SmaregiMemberProduct.new(kaiin_id:data[0][0],product_id:data[0][1],early_number_of_purchase:0,total_number_of_purchase:data[1])
			end
		end
		SmaregiMemberProduct.import new_arr
	end
end