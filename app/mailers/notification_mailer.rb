class NotificationMailer < ActionMailer::Base
  default from: "d@bento.jp"

  def send_order(order,vendor)
    @vendor = vendor
    @materials_this_vendor = Material.get_material_this_vendor(order.id,@vendor.id)
    filename = "#{Time.now.strftime('%y%m%d')}_taberu.pdf"
    attachments[filename] = OrderPdf.new(@materials_this_vendor,@vendor).render
    mail(
      subject: "#{@vendor.company_name} 御中", #メールのタイトル
      to: @vendor.efax_address, #宛先
      cc: "81359375432@efaxsend.com"
    ) do |format|
      format.text
    end
  end
end
