require 'net/imap'
require 'kconv'
require 'mail'
require 'nkf'

class KurumesiMail < ApplicationRecord
  belongs_to :kurumesi_order, optional: true

  enum summary: {その他:0, 新規オーダー:1,内容変更:2,キャンセル:3}

  def self.search(params)
    if params
      data = KurumesiMail.order(recieved_datetime: "DESC").all
      data = data.where(kurumesi_order_id: params["kurumesi_order_id"]) if params["kurumesi_order_id"].present?
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
    # テスト
    # search_criterias = [
    #   'FROM','gon@bento.jp',
    #   'SINCE', (Date.today).strftime("%d-%b-%Y")
    # ]
    # 本番
    search_criterias = [
      'FROM','info@kurumesi-bentou.com',
      'SINCE', (Date.today).strftime("%d-%b-%Y")
    ]

    imap.select('INBOX') # 対象のメールボックスを選択
    ids = imap.search(search_criterias) # 全てのメールを取得
    ids.each_slice(100).to_a.each do |id_block| # 100件ごとにメールをfetchする
      imap.fetch(ids, ["RFC822", "ENVELOPE"]).each do |mail|
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
          # body = m.body.decoded.encode("UTF-8", m.charset)
          body = m.body.decoded.toutf8
        end
        unless KurumesiMail.find_by(body:body,recieved_datetime:recieved_datetime).present?
          @kurumei_mail = KurumesiMail.new
          @kurumei_mail.subject = subject
          @kurumei_mail.body = body
          @kurumei_mail.recieved_datetime = recieved_datetime
          @kurumei_mail.kurumesi_order_reflect_flag = false
          # kurumei_mailの作成
          if subject.include?("ご注文がありました")
            @kurumei_mail.summary = 1
            @kurumei_mail.save
            order_info_from_mail = input_order(body)
            new_order(order_info_from_mail) unless KurumesiOrder.where(management_id:order_info_from_mail[:management_id]).present?
          elsif subject.include?("変更致しました")
            @kurumei_mail.summary = 2
            @kurumei_mail.save
            order_info_from_mail = input_order(body)
            update_order(order_info_from_mail)
          elsif subject.include?("キャンセルさせて頂きました")
            @kurumei_mail.summary = 3
            @kurumei_mail.save
            order_info_from_mail = input_order(body)
            cancel_order(order_info_from_mail)
          else
            @kurumei_mail.summary = 0
            @kurumei_mail.save
          end
        end
      end
    end
    user = User.find(1)
    now = Time.now
    user.update(last_mail_check:now)
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
    brand_name = body[0,body.index("｜")]
    order[:brand_id] = Brand.find_by(name:brand_name).id
    info_arr.join('').gsub('[','$$$').split("$$$").reject(&:blank?).each do |line|
      order[:delivery_date] = line[5..14] if line[0..3] == "配達日時"
      order[:management_id] = line[5..-1].to_i if line[0..3] == "注文番号"
      if line[0..3]== "支払方法"
        if line[5..7] == '請求書'
          order[:pay] = 0
        elsif line[5..7] == "現金"
          order[:pay] = 1
        else
          order[:pay] = 2
        end
      end
    end
    shohin_arr.join('').gsub('【','$$$').gsub('[請求金額]','$$$').split("$$$").reject(&:blank?).each do |line|
      product_name = ""
      num = ""
      if line.index('】').present?
        product_name_end_kakko = line.index('】') - 1
        product_name = line[0..product_name_end_kakko]

        # product_id = Product.find_by(name:product_name).id
        product = Product.find_by(name:product_name)
        if product.present?
          product_id = product.id
          num = line.match(/×(.+)食/)[1].to_i
          order_details_arr << {product_id:product_id,num:num}
          # 味噌有無
          if line.include?('味噌汁付き')
            order_details_arr << {product_id:3831,num:num}
          end
          # 茶の有無
          if line.include?('ペット茶')
            order_details_arr << {product_id:3791,num:num}
          elsif line.include?('缶茶')
            order_details_arr << {product_id:3801,num:num}
          end
        end
      end
    end
    #重複はまとめる！
    order[:order_details] = order_details_arr.group_by{ |i| i[:product_id]}
      .map{|k, v|
         v[1..-1].each {|x| v[0][:num] += x[:num]}
         v[0]
       }
    order
  end

  def self.new_order(order_info_from_mail)
    @kurumesi_order = KurumesiOrder.new
    @kurumesi_order.start_time = order_info_from_mail[:delivery_date]
    @kurumesi_order.brand_id = order_info_from_mail[:brand_id]
    @kurumesi_order.management_id = order_info_from_mail[:management_id]
    @kurumesi_order.payment = order_info_from_mail[:pay]
    order_info_from_mail[:order_details].each do |od|
      @kurumesi_order.kurumesi_order_details.build(product_id:od[:product_id],number:od[:num])
    end
    reflect_check()
  end

  def self.update_order(order_info_from_mail)
    @kurumesi_order = KurumesiOrder.find_by(management_id:order_info_from_mail[:management_id])
    if @kurumesi_order.present?
      #詳細をすべて一旦削除
      @kurumesi_order.kurumesi_order_details.destroy_all
    else
      @kurumesi_order = KurumesiOrder.new
    end
    @kurumesi_order.start_time = order_info_from_mail[:delivery_date]
    @kurumesi_order.payment = order_info_from_mail[:pay]
    order_info_from_mail[:order_details].each do |od|
      @kurumesi_order.kurumesi_order_details.build(product_id:od[:product_id],number:od[:num])
    end
    reflect_check()
  end

  def self.cancel_order(order_info_from_mail)
    @kurumesi_order = KurumesiOrder.find_by(management_id:order_info_from_mail[:management_id])
    @kurumesi_order.canceled_flag = true
    reflect_check()
  end

  def self.reflect_check()
    if @kurumesi_order.save
      @kurumei_mail.update(kurumesi_order_reflect_flag:true,kurumesi_order_id: @kurumesi_order.id)
    else
      @kurumei_mail.update(kurumesi_order_reflect_flag:false)
    end
  end
end
