class NotificationMailer < ActionMailer::Base
  default from: "masahiro11g@gmail.com"

  def send_fax_order(order,vendor)
    @vendor = vendor
    @order = order
    @materials_this_vendor = Material.get_material_this_vendor(order.id,@vendor.id)
    num = @materials_this_vendor.map{|om|om.delivery_date}.uniq.length
    filename = "#{Time.now.strftime('%y%m%d')}_order_fax.pdf"
    if vendor.id == 549 ||vendor.id == 261
      attachments[filename] = NpOrderPdf.new(@materials_this_vendor,@vendor,order).render
    else
      attachments[filename] = OrderPdf.new(@materials_this_vendor,@vendor,order).render
    end
    mail(subject: "CR36837533000",to:"movfax@mail01.lcloud.jp") do |format|
      format.text
    end
  end

  def send_error_notice(recieved_datetime,body)
    @recieved_datetime = recieved_datetime.strftime("%Y/%m/%d/%H:%M")
    @body = body
    mail(
      subject: "くるめし連携エラー", #メールのタイトル
      to: 'bejihan.orderecipe@gmail.com',

    ) do |format|
      format.text
    end
  end

end
