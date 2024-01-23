class ItemVendor < ApplicationRecord
	has_many :items
	enum payment: {請求書:1,振込用紙:2,現金:3}
	enum sorting_base_id: {なし:0,べじはん:1,SKL練馬:2}
end
