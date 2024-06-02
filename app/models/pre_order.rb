class PreOrder < ApplicationRecord

	enum status: {新規注文:0,確認:1,準備完了:2,"受渡・決済完了":3,キャンセル:4}

	has_many :pre_order_products, dependent: :destroy
  	accepts_nested_attributes_for :pre_order_products, allow_destroy: true, reject_if: lambda { |attributes|
		attributes.merge!({_destroy: 1}) if attributes['order_num'] == "0"
	}
	belongs_to :store
	after_create :store_notify
	
	def self.twilio_client
		account_sid = Orderecipe::Application.config.twilio_config[:account_sid]
		auth_token = Orderecipe::Application.config.twilio_config[:auth_token]
		@client ||= Twilio::REST::Client.new account_sid, auth_token
	end

	def store_notify
		PreOrder.twilio_client.calls.create(
	  		from: "+17082943574",
	  		to:   self.store.phone.gsub('-', '').gsub(/\A0/,'+81'),
	  		url: 'https://twimlets.com/echo?Twiml=%3CResponse%3E%0A++%3CPause+length%3D%222%22%2F%3E%0A++%3CSay+voice%3D%22woman%22+language%3D%22ja-jp%22%3E%E6%9F%B4%E7%94%B0%E5%B1%8B%E7%A4%BE%E5%93%A1%E3%81%8B%E3%82%89%E6%B3%A8%E6%96%87%E3%81%8C%E5%85%A5%E3%82%8A%E3%81%BE%E3%81%97%E3%81%9F%E3%80%82%3C%2FSay%3E%0A%3C%2FResponse%3E'
		)
	rescue
		# code = $!.code rescue nil # TimeOut 等の場合は、code が返ってこないので
		# 失敗した場合は、エラーコードと、エラーメッセージを保存
		# update(result: 1, error_code: code, error_message: $!.message)
	end
end
