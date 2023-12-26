class ToStoreMessageStore < ApplicationRecord
	belongs_to :to_store_message
	belongs_to :store
end
