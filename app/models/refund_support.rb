class RefundSupport < ApplicationRecord
  enum status: {do:0,done:1}
  belongs_to :store
end
