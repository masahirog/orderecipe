class NotificationMailer < ActionMailer::Base
  default from: "d@bento.jp"

  def send_order(vendor)
    @vendor = vendor
    mail(
      subject: "発注のFAXをお送りします", #メールのタイトル
      to: @vendor.efax_address #宛先
    ) do |format|
      format.text
    end
  end
end
