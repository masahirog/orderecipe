require 'net/imap'
require 'kconv'
require 'mail'

class KurumesiMail < ApplicationRecord
  belongs_to :masu_order, optional: true

  enum summary: {その他:0, 新規オーダー:1,内容変更:2,キャンセル:3}

  def self.search(params)
    if params
      data = KurumesiMail.order(recieved_datetime: "DESC").all
      # data = data.where(['name LIKE ?', "%#{params["name"]}%"]) if params["name"].present?
      # data = data.where(['order_name LIKE ?', "%#{params["order_name"]}%"]) if params["order_name"].present?
      data = data.where(masu_order_id: params["masu_order_id"]) if params["masu_order_id"].present?
      # data = data.where(['order_code LIKE ?', "%#{params["order_code"]}%"]) if params["order_code"].present?
      # data = data.where(['end_of_sales LIKE ?', "%#{params["end_of_sales"]["value"]}%"]) if params["end_of_sales"].present?
      # data = data.where(storage_location_id:params[:storage_location_id]) if params[:storage_location_id].present?
      data
    else
       KurumesiMail.order(recieved_datetime: "DESC").all
    end
  end

  def self.routine_check
    # imapに接続
    imap_host = 'imap.gmail.com' # imapをgmailのhostに設定する
    imap_usessl = true # imapのsslを有効にする
    imap_port = 993 # ssl有効なら993、そうでなければ143
    imap = Net::IMAP.new(imap_host, imap_port, imap_usessl)
    # imapにログイン
    imap_user = 'gon@bento.jp'
    imap_passwd = 'rohisama'
    imap.login(imap_user, imap_passwd)
    search_criterias = [
      'FROM','info@kurumesi-bentou.com',
      'SINCE', (Date.today).strftime("%d-%b-%Y")
    ]

    imap.select('INBOX') # 対象のメールボックスを選択
    ids = imap.search(search_criterias) # 全てのメールを取得
    ids.each_slice(100).to_a.each do |id_block| # 100件ごとにメールをfetchする
      imap.fetch(id_block, "RFC822").each do |mail|
        m = Mail.new(mail.attr["RFC822"])
        subject = m.subject
        recieved_datetime = m.date
        if m.multipart?
          if m.text_part
            body = m.text_part.decoded
          elsif m.html_part
            body = m.html_part.decoded
          end
        else
          body = m.body.decoded.encode("UTF-8", m.charset)
        end

        unless KurumesiMail.find_by(body:body,recieved_datetime:recieved_datetime).present?
          @kurumei_mail = KurumesiMail.new
          @kurumei_mail.subject = subject
          @kurumei_mail.body = body
          @kurumei_mail.recieved_datetime = recieved_datetime
          # kurumei_mailの作成
          if subject.include?("ご注文がありました")
            @kurumei_mail.status = 1
            order_info_from_mail = input_order(body)
            new_order(order_info_from_mail) unless MasuOrder.where(kurumesi_order_id:order_info_from_mail[:kurumesi_order_id]).present?
          elsif subject.include?("変更致しました")
            @kurumei_mail.status = 2
            order_info_from_mail = input_order(body)
            update_order(order_info_from_mail)

          elsif subject.include?("キャンセルさせて頂きました")
            @kurumei_mail.status = 3
            order_info_from_mail = input_order(body)
            cancel_order(order_info_from_mail)
          else
            @kurumei_mail.status = 0
            @kurumei_mail.save
          end
        end
      end
    end
  end


  def self.input_order(body)
    arr = []
    order_details_arr = []
    body.gsub(" ", "").gsub("　","").each_line{|string| arr << string.strip}
    arr = arr.compact.reject(&:empty?)
    order_info_index = arr.index("┏▼ご注文情報━━━━━━━━━━━━━━━━━━━━━━━━━━━┓")
    shohin_index = arr.index("┏▼ご注文商品━━━━━━━━━━━━━━━━━━━━━━━━━━━┓")
    info_arr = arr[order_info_index..shohin_index-1]
    shohin_arr = arr[shohin_index+1..-1]
    order = {}

    info_arr.each do |line|
      order[:delivery_date] = line[6..15] if line[0..5] == "[配達日時]"
      order[:kurumesi_order_id] = line[6..-1].to_i if line[0..5] == "[注文番号]"
      if line[0..5]== "[支払方法]"
        if line[6..7] == '請求'
          order[:pay] = 0
        else
          order[:pay] = 1
        end
      end
    end
    order[:miso] = 0
    order[:tea] = 0
    order[:trash_bags] = 0
    shohin_arr.join('').gsub('【','$$$').gsub('[請求金額]','$$$').split("$$$").reject(&:blank?).each do |line|
      product_name = ""
      num = ""

      #ごみ袋
      order[:trash_bags] = line.match(/×(.+)食/)[1].to_i if line.include?("ゴミ袋")

      # 茶の有無
      if line.include?('ペット茶')
        order[:tea] = 1
      elsif line.include?('缶茶')
        order[:tea] = 2
      end
      # 味噌有無
      order[:miso] = 1 if line.include?('味噌汁付き')
      if line.index('】').present?
        product_name_end_kakko = line.index('】') - 1
        product_name = line[0..product_name_end_kakko]

        # product_id = Product.find_by(name:product_name).id
        product = Product.find_by(name:product_name)
        if product.present?
          product_id = product.id
          num = line.match(/×(.+)食/)[1].to_i if line.match(/×(.+)食/).present?
          order_details_arr << {product_id:product_id,num:num}
        end
      end
    end
    order[:order_details] = order_details_arr
    order
  end

  def self.new_order(order_info_from_mail)
    @masu_order = MasuOrder.new
    @masu_order.start_time = order_info_from_mail[:delivery_date]
    @masu_order.kurumesi_order_id = order_info_from_mail[:kurumesi_order_id]
    @masu_order.payment = order_info_from_mail[:pay]
    @masu_order.miso = order_info_from_mail[:miso]
    @masu_order.number = order_info_from_mail[:order_details].sum { |hash| hash[:num]}
    @masu_order.trash_bags = order_info_from_mail[:trash_bags]
    @masu_order.tea = order_info_from_mail[:tea]
    order_info_from_mail[:order_details].each do |od|
      @masu_order.masu_order_details.build(product_id:od[:product_id],number:od[:num])
    end
    reflect_check()
  end

  def self.update_order(order_info_from_mail)
    @masu_order = MasuOrder.find_by(kurumesi_order_id:order_info_from_mail[:kurumesi_order_id])
    if @masu_order.present?
      #詳細をすべて一旦削除
      @masu_order.masu_order_details.destroy_all
    else
      @masu_order = MasuOrder.new
    end

    @masu_order.start_time = order_info_from_mail[:delivery_date]
    @masu_order.payment = order_info_from_mail[:pay]
    @masu_order.miso = order_info_from_mail[:miso]
    @masu_order.number = order_info_from_mail[:order_details].sum { |hash| hash[:num]}
    @masu_order.trash_bags = order_info_from_mail[:trash_bags]
    @masu_order.tea = order_info_from_mail[:tea]
    order_info_from_mail[:order_details].each do |od|
      @masu_order.masu_order_details.build(product_id:od[:product_id],number:od[:num])
    end
    reflect_check()
  end

  def self.cancel_order(order_info_from_mail)
    @masu_order = MasuOrder.find_by(kurumesi_order_id:order_info_from_mail[:kurumesi_order_id])
    @masu_order.canceled_flag = true
    reflect_check()
  end

  def self.reflect_check()
    if @masu_order.save
      @kurumei_mail.masu_order_id = @masu_order.id
      @kurumei_mail.masu_order_reflect_flag = true
    else
      @kurumei_mail.masu_order_reflect_flag = false
    end
    @kurumei_mail.save
  end
end
