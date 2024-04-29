class NotificationMailer < ActionMailer::Base

  # default from: "masahiro11g@gmail.com"
  default from: "m.yamashita@shibata-ya.jp"

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
  def send_mail_order(order,vendor)
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
    mail(subject: "発注のご連絡",to:@vendor.company_mail) do |format|
      format.text
    end
  end

  def coupon(store,to,coupon,souzai_url,bento_url,gyusuji_url)
    @store = store
    @coupon = coupon
    @souzai_url = souzai_url
    @bento_url = bento_url
    @gyusuji_url = gyusuji_url
    mail(subject: "【再送】アンケートのお礼｜べじはん",to:to,cc:'m.yamashita@shibata-ya.jp') do |format|
      format.text
    end
  end
end
