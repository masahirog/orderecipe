class Item < ApplicationRecord
	belongs_to :item_vendor
	enum category: {vegtable:1,fruit:2,processed_goods:3}
	enum unit: {袋:1,cs:2,本:3,kg:4,個:5,pc:6}
end
