class WorkType < ApplicationRecord
	has_many :working_hour_work_types
	enum category: {当日準備:1,タレ:2,切出:3,調理:4,積載:5,洗浄掃除:6,翌日準備:7,発注:8,休憩:9,その他:10,商品開発:11}
	def view_name_category
		self.category + "｜" + self.name
	end
end
