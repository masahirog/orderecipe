class Item < ApplicationRecord
	belongs_to :item_vendor
	enum category: {野菜:1,果物:2,物産:3,送料:4}
	enum unit: {袋:1,cs:2,本:3,kg:4,個:5,pc:6}
	def view_name_and_variety
		self.name + "　" + self.variety
	end
end
