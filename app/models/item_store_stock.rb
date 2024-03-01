class ItemStoreStock < ApplicationRecord
	belongs_to :item
	belongs_to :store
	enum unit: {袋:1,cs:2,本:3,kg:4,個:5,pc:6,口:7}
end
