class ItemExpirationDate < ApplicationRecord
	belongs_to :item
	def self.expiration_date_notice
		today = Date.today
		ItemExpirationDate.where(notice_date:today).each do |ied|
			item = ied.item
			Slack::Notifier.new("https://hooks.slack.com/services/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", username: 'Bot', icon_emoji: ':chicken:').ping("賞味期限が迫ってきました！\nーーー\n#{item.name} #{item.variety}｜#{item.item_vendor.store_name}\n期限：#{ied.expiration_date}\n数：#{ied.number}\nーーー")
		end
	end
end
