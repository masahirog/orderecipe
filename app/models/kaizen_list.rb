class KaizenList < ApplicationRecord
  belongs_to :product
  enum status: {yet:0,do:1,done:2,skip:3,cancel:4}
end
