class NotificationMailer < ActionMailer::Base
  default from: "d@bento.jp"

  def send_order(order,vendor)
    @vendor = vendor
    @materials_this_vendor = Material.get_material_this_vendor(order.id,@vendor.id)
    num = @materials_this_vendor.map{|om|om.delivery_date}.uniq.length
    filename = "#{Time.now.strftime('%y%m%d')}_taberu.pdf"
    attachments[filename] = OrderPdf.new(@materials_this_vendor,@vendor,order).render
    mail(
      subject: "#{@vendor.company_name}様 オーダーID：#{order.id} 計：#{num}枚", #メールのタイトル
      to: @vendor.efax_address
    ) do |format|
      format.text
    end
  end
end
