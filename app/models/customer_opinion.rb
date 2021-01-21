class CustomerOpinion < ApplicationRecord
  def self.post_shere(customer_opinion)
    line_notify = LineNotify.new('V77tCISPuOwwxsSWTZEBHJjonL4LH1PBwVVEaXXlx9F')
    options = {
      message: "\n#{customer_opinion.content}"
    }
    line_notify.ping(options)
  end
end
# テスト：TQe4fwSwkJ7hNvtAsI00MDCxNnKC3QmHtYesQUPmJqJ
# 本番：V77tCISPuOwwxsSWTZEBHJjonL4LH1PBwVVEaXXlx9F
