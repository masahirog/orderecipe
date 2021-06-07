class CustomerOpinion < ApplicationRecord
  def self.post_shere(customer_opinion)
    NotificationMailer.co_send_mail(customer_opinion.content).deliver
  end
end
# テスト：TQe4fwSwkJ7hNvtAsI00MDCxNnKC3QmHtYesQUPmJqJ
# 本番：V77tCISPuOwwxsSWTZEBHJjonL4LH1PBwVVEaXXlx9F
