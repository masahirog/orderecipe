class NotificationMailer < ActionMailer::Base
  default from: "m.yamashita@jfd.co.jp"
  def sales_report_send(sales_report,analysis,sozai_ureyuki,bento_ureyuki)
    @sales_report = sales_report
    @analysis = analysis
    @sozai_ureyuki = sozai_ureyuki
    @bento_ureyuki = bento_ureyuki
    mail(
      subject: "べじはんフォーム", #メールのタイトル
      to: 'kitchen@taberu.co.jp',
    ) do |format|
      format.text
    end
  end
  def send_order(order,vendor)
    @vendor = vendor
    @materials_this_vendor = Material.get_material_this_vendor(order.id,@vendor.id)
    num = @materials_this_vendor.map{|om|om.delivery_date}.uniq.length
    filename = "#{Time.now.strftime('%y%m%d')}_taberu.pdf"
    if vendor.id == 549
      attachments[filename] = NpOrderPdf.new(@materials_this_vendor,@vendor,order).render
    else
      attachments[filename] = OrderPdf.new(@materials_this_vendor,@vendor,order).render
    end
    mail(
      subject: "オーダーID：#{order.id},担当：#{order.staff_name},計：#{num}枚", #メールのタイトル
      to: @vendor.efax_address
    ) do |format|
      format.text
    end
  end
  def co_send_mail(co)
    @co = co
    mail(
      subject: "customer_voice", #メールのタイトル
      to: 'kitchen@taberu.co.jp',

    ) do |format|
      format.text
    end
  end

  def task_create_send_mail(task,store_ids)
    @task = task
    @store_names = [@task.store.name]
    if store_ids.present?
      @store_names << Store.where(id:store_ids.keys).pluck(:name)
    end
    mail(
      subject: "task_create", #メールのタイトル
      to: 'kitchen@taberu.co.jp',

    ) do |format|
      format.text
    end
  end
  def kaizen_list_create_send_mail(kaizen_list)
    @kaizen_list = kaizen_list
    mail(
      subject: "kaizen_list_create",
      to: 'kitchen@taberu.co.jp',

    ) do |format|
      format.text
    end
  end

  def send_error_notice(recieved_datetime,body)
    @recieved_datetime = recieved_datetime.strftime("%Y/%m/%d/%H:%M")
    @body = body
    mail(
      subject: "くるめし連携エラー", #メールのタイトル
      to: 'kitchen@taberu.co.jp',

    ) do |format|
      format.text
    end
  end

  def send_kurumesi_capa_notice(date,num)
    @date = date
    @num = num
    mail(
      subject: "くるめしキャパオーバー", #メールのタイトル
      to: 'kitchen@taberu.co.jp',
    ) do |format|
      format.text
    end
  end

end
