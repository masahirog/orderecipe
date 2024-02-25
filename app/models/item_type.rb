class ItemType < ApplicationRecord
	has_many :item_varieties
	enum category: {野菜:1,果実:2,物産品:3,送料:4}
end
