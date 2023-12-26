class ToStoreMessage < ApplicationRecord
	has_many :to_store_message_stores, dependent: :destroy
	has_many :stores,through: :to_store_message_stores
 	accepts_nested_attributes_for :to_store_message_stores, allow_destroy: true
end
