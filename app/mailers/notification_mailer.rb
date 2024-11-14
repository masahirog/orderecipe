class NotificationMailer < ActionMailer::Base

  # default from: "masahiro11g@gmail.com"
  default from: "m.yamashita@shibata-ya.jp"

  def send_fax_order(order,vendor)
    @vendor = vendor
    @order = order
    @materials_this_vendor = Material.get_material_this_vendor(order.id,@vendor.id)
    num = @materials_this_vendor.map{|om|om.delivery_date}.uniq.length
    filename = "order_#{order.id}_#{vendor.name}"
    template_path = if vendor.id == 549 || vendor.id == 261
                      'orders/np_order_print'
                    else
                      'orders/order_print'
                    end
    pdf_html = render_to_string(
      template: template_path,
      layout: 'pdf',
      encoding: 'UTF-8'
    )
    pdf = WickedPdf.new.pdf_from_string(pdf_html, encoding: 'UTF-8')
    # PDFを一時ファイルに保存し、添付
    temp_pdf = Tempfile.new(["order_#{order.id}_#{vendor.name}", '.pdf'], "#{Rails.root}/tmp")
    temp_pdf.binmode
    temp_pdf.write(pdf)
    temp_pdf.rewind

    # 添付ファイルとしてPDFを読み込み
    attachments[filename] = {
      mime_type: 'application/pdf',
      content: File.read(temp_pdf.path)
    }

    temp_pdf.close
    temp_pdf.unlink
    #△この処理を挟まないと、メール送信時に文字化けする
    mail(subject: "CR36837533000",to:"movfax@mail01.lcloud.jp") do |format|
      format.text
    end
  end
  def send_mail_order(order,vendor)
    @vendor = vendor
    @order = order
    @materials_this_vendor = Material.get_material_this_vendor(order.id,@vendor.id)
    num = @materials_this_vendor.map{|om|om.delivery_date}.uniq.length
    filename = "order_#{order.id}_#{vendor.name}"
    template_path = if vendor.id == 549 || vendor.id == 261
                      'orders/np_order_print'
                    else
                      'orders/order_print'
                    end
    pdf_html = render_to_string(
      template: template_path,
      layout: 'pdf',
      encoding: 'UTF-8'
    )
    pdf = WickedPdf.new.pdf_from_string(pdf_html, encoding: 'UTF-8')
    # PDFを一時ファイルに保存し、添付
    temp_pdf = Tempfile.new(["order_#{order.id}_#{vendor.name}", '.pdf'], "#{Rails.root}/tmp")
    temp_pdf.binmode
    temp_pdf.write(pdf)
    temp_pdf.rewind
    # 添付ファイルとしてPDFを読み込み
    attachments[filename] = {
      mime_type: 'application/pdf',
      content: File.read(temp_pdf.path)
    }
    temp_pdf.close
    temp_pdf.unlink

    mail(subject: "発注のご連絡",to:@vendor.company_mail) do |format|
      format.text
    end
  end
end
