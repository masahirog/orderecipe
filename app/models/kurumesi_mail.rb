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
    imap_user = 'd@bento.jp'
    imap_passwd = ENV['D_BENTO_PASS']
    imap.login(imap_user, imap_passwd)
    # 'FROM','info@kurumesi-bentou.com',
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
          begin
          # 例外が起こるかも知れないコード
            body = m.body.decoded.encode("UTF-8", m.charset)
          rescue => error # 変数(例外オブジェクトの代入)
          # 例外が発生した時のコード
            next
          end
        end
        #波ダッシュなどの置換
        mappings = {
          "\u{00A2}" => "\u{FFE0}",
          "\u{00A3}" => "\u{FFE1}",
          "\u{00AC}" => "\u{FFE2}",
          "\u{2016}" => "\u{2225}",
          "\u{2012}" => "\u{FF0D}",
          "\u{301C}" => "\u{FF5E}"
        }
        mappings.each{|before, after| body = body.gsub(before, after) }
        body = body.encode(Encoding::Windows_31J, undef: :replace).encode(Encoding::UTF_8)
        unless KurumesiMail.find_by(body:body,recieved_datetime:recieved_datetime).present?
          @kurumei_mail = KurumesiMail.new
          @kurumei_mail.subject = subject
          @kurumei_mail.body = body
          @kurumei_mail.recieved_datetime = recieved_datetime
          @kurumei_mail.kurumesi_order_reflect_flag = false
          # kurumei_mailの作成
          if subject.include?("ご注文がありました")
            @kurumei_mail.summary = 1
            # @kurumei_mail.save
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
    brand_id = Brand.find_by(name:brand_name).id
    order[:brand_id] = brand_id
    s = shohin_arr.join.index("[請求金額]") + 6
    e = shohin_arr.join.index("円",s) - 1
    order[:total_price] = shohin_arr.join[s..e].delete(",").to_i
    info_arr.each do |line|
      order[:company_name] = line[5..-1] if line[1..3] == "会社名"
      if line[1..4] == "配達日時"
        order[:delivery_date] = line[6..15]
        order[:delivery_time] = line[19..23]
      elsif line[1..4] == "担当者様"
        order[:staff_name] = line[6..-2]
      elsif line[1..4] == "お届け先"
        order[:delivery_address] = line[6..-1]
      elsif line[1..4] == "注文番号"
        order[:management_id] = line[6..-1].to_i
      elsif line[1..4] == "宛名指定"
        order[:reciept_name] = line[6..-1]
      elsif line[1..4] == "連絡事項"
        memo = true
      elsif line[1..4]== "支払方法"
        if line[6..8] == "現金"
          order[:pay] = 1
        else
          order[:pay] = 2
        end
        if memo == true
        end
      end
      if line[1..2] == "但書"
        order[:proviso] = line[4..-1]
      elsif line[1..2] == "受渡"
        if line[4..-1] == "当日請求書持参"
          order[:pay] = 0
        else
          order[:pay] = 3
        end
      end
      order[:proviso] = line[7..-1] if line[1..5] == "領収書但書"
    end

    shohin_arr.join('').gsub('【','$$$').gsub('[請求金額]','$$$').split("$$$").reject(&:blank?).each do |line|
      product_name = ""
      num = ""
      if brand_id == 11
        Brand.masu_order_make(order_details_arr,line,product_name,num)
      elsif brand_id == 21
        Brand.hasisaji_order_make(order_details_arr,line,product_name,num)
      elsif brand_id == 31
        Brand.donburi_order_make(order_details_arr,line,product_name,num)
      elsif brand_id == 51
        Brand.suzukaze_order_make(order_details_arr,line,product_name,num)
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
    @kurumesi_order.delivery_time = order_info_from_mail[:delivery_time]
    @kurumesi_order.brand_id = order_info_from_mail[:brand_id]
    @kurumesi_order.management_id = order_info_from_mail[:management_id]
    @kurumesi_order.payment = order_info_from_mail[:pay]
    @kurumesi_order.total_price = order_info_from_mail[:total_price]
    @kurumesi_order.company_name = order_info_from_mail[:company_name]
    @kurumesi_order.staff_name = order_info_from_mail[:staff_name]
    @kurumesi_order.delivery_address = order_info_from_mail[:delivery_address]
    @kurumesi_order.reciept_name = order_info_from_mail[:reciept_name]
    @kurumesi_order.proviso = order_info_from_mail[:proviso]
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
    @kurumesi_order.delivery_time = order_info_from_mail[:delivery_time]
    @kurumesi_order.payment = order_info_from_mail[:pay]
    @kurumesi_order.total_price = order_info_from_mail[:total_price]
    @kurumesi_order.company_name = order_info_from_mail[:company_name]
    @kurumesi_order.staff_name = order_info_from_mail[:staff_name]
    @kurumesi_order.delivery_address = order_info_from_mail[:delivery_address]
    @kurumesi_order.reciept_name = order_info_from_mail[:reciept_name]
    @kurumesi_order.proviso = order_info_from_mail[:proviso]
    @kurumesi_order.confirm_flag = false
    @kurumesi_order.capture_done = false
    order_info_from_mail[:order_details].each do |od|
      @kurumesi_order.kurumesi_order_details.build(product_id:od[:product_id],number:od[:num])
    end
    reflect_check()
  end

  def self.cancel_order(order_info_from_mail)
    @kurumesi_order = KurumesiOrder.find_by(management_id:order_info_from_mail[:management_id])
    @kurumesi_order.canceled_flag = true
    @kurumesi_order.confirm_flag = false
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
