require 'net/imap'
require 'kconv'
require 'mail'
require 'nkf'

class Order < ApplicationRecord
  paginates_per 20
  has_many :order_materials, dependent: :destroy
  has_many :materials, through: :order_materials
  accepts_nested_attributes_for :order_materials, reject_if: :reject_material_blank, allow_destroy: true

  has_many :order_products, dependent: :destroy
  has_many :products, through: :order_products
  accepts_nested_attributes_for :order_products, allow_destroy: true, update_only: true
  belongs_to :store
  before_save :initialize_stock
  #納品量の追加
  after_save :input_stock

  def initialize_stock
    stock_ids = []
    stocks_arr = []
    update_stocks = []
    @dates = []


    before_dates = self.order_materials.map{|om|om.delivery_date_was}.uniq
    after_dates = self.order_materials.map{|om|om.delivery_date}.uniq
    @dates = (before_dates + after_dates).uniq
    stocks = Stock.where(store_id:self.store_id,date:@dates)
    # stocks.update_all(delivery_amount:0)
    stocks.each do |stock|
      stock.end_day_stock = stock.start_day_stock - stock.used_amount
      stock.delivery_amount = 0
      stocks_arr << stock
      stock_ids << stock.id
    end

    # キッチン商品の在庫を動かす
    material_ids = stocks.map{|stock|stock.material_id}.uniq
    materials = Material.where(id:material_ids,vendor_id:559)
    stocks = Stock.where(store_id:39,date:@dates,material_id:materials.ids)
    stocks.each do |stock|
      stock.end_day_stock = stock.start_day_stock + stock.delivery_amount
      stock.used_amount = 0
      stocks_arr << stock
      stock_ids << stock.id
    end
    
    Stock.import stocks_arr,on_duplicate_key_update:[:used_amount,:delivery_amount,:end_day_stock] if stocks_arr.present?
    Stock.where(id:stock_ids).each do |stock|
      Stock.change_stock(update_stocks,stock.material_id,stock.date,stock.end_day_stock,stock.store_id)
    end
    Stock.import update_stocks, on_duplicate_key_update:[:end_day_stock,:start_day_stock] if update_stocks.present?
    self.order_materials.each do |om|
      if om.order_quantity == "0"
        om.un_order_flag = true
      end
    end
  end


  def input_stock
    new_stocks = []
    update_stocks = []
    order_materials = OrderMaterial.where(un_order_flag:false).joins(:order).where(:orders => {fixed_flag:true,store_id:self.store_id}).where(delivery_date:@dates)
    order_materials_group = order_materials.order('delivery_date asc').group('delivery_date').group('material_id').sum(:order_quantity)
    materials_hash = Material.where(id:order_materials.map{|om|om.material_id}.uniq).map{|material|[material.id,material]}.to_h
    order_materials_group.each do |omg|
      date = omg[0][0]
      material_id = omg[0][1]
      material = materials_hash[material_id]
      delivery_amount = omg[1].to_f
      stock = Stock.find_by(date:date,material_id:material_id,store_id:self.store_id)
      if stock
        stock.delivery_amount = delivery_amount
        end_day_stock = stock.start_day_stock - stock.used_amount + delivery_amount
        stock.end_day_stock = end_day_stock
        update_stocks << stock
      else
        prev_stock = Stock.where(store_id:self.store_id).where("date < ?", date).where(material_id:material_id).order("date DESC").first
        if prev_stock.present?
          start_day_stock = prev_stock.end_day_stock
          end_day_stock = start_day_stock + delivery_amount
          new_stocks << Stock.new(material_id:material_id,date:date,end_day_stock:end_day_stock,start_day_stock:start_day_stock,delivery_amount:delivery_amount,store_id:self.store_id)
        else
          end_day_stock = delivery_amount
          new_stocks << Stock.new(material_id:material_id,date:date,end_day_stock:end_day_stock,delivery_amount:delivery_amount,store_id:self.store_id)
        end
      end
    end
    # キッチンの在庫を動かす
    kitchen_order_materials = OrderMaterial.where(un_order_flag:false).joins(:material).where(:materials => {vendor_id:559}).joins(:order).where(:orders => {fixed_flag:true}).where(delivery_date:@dates)
    kitchen_order_materials_group = kitchen_order_materials.order('delivery_date asc').group('delivery_date').group('material_id').sum(:order_quantity)
    kitchen_materials_hash = Material.where(id:kitchen_order_materials.map{|om|om.material_id}.uniq).map{|material|[material.id,material]}.to_h
    kitchen_order_materials_group.each do |omg|
      
      date = omg[0][0]
      material_id = omg[0][1]
      material = kitchen_materials_hash[material_id]
      used_amount = omg[1].to_f
      stock = Stock.find_by(date:date,material_id:material_id,store_id:39)
      if stock
        stock.used_amount = used_amount
        end_day_stock = stock.start_day_stock - stock.used_amount + stock.delivery_amount
        stock.end_day_stock = end_day_stock
        update_stocks << stock
      else
        prev_stock = Stock.where(store_id:39).where("date < ?", date).where(material_id:material_id).order("date DESC").first
        if prev_stock.present?
          start_day_stock = prev_stock.end_day_stock
          end_day_stock = start_day_stock - used_amount
          new_stocks << Stock.new(material_id:material_id,date:date,end_day_stock:end_day_stock,start_day_stock:start_day_stock,delivery_amount:0,store_id:39,used_amount:used_amount)
        else
          end_day_stock = - used_amount
          new_stocks << Stock.new(material_id:material_id,date:date,end_day_stock:end_day_stock,delivery_amount:0,used_amount:used_amount,store_id:39)
        end
      end
    end
    Stock.import new_stocks if new_stocks.present?
    Stock.import update_stocks, on_duplicate_key_update:[:used_amount,:delivery_amount,:end_day_stock] if update_stocks.present?
    
    order_materials = order_materials.group('material_id').minimum(:delivery_date)
    kitchen_order_materials = kitchen_order_materials.group('material_id').minimum(:delivery_date)
    update_stocks = []
    order_materials.each do |om|
      material_id = om[0]
      date = om[1]
      material = materials_hash[material_id]
      stock = Stock.find_by(date:date,material_id:material_id,store_id:self.store_id)
      end_day_stock = stock.start_day_stock - stock.used_amount + stock.delivery_amount
      Stock.change_stock(update_stocks,material_id,date,end_day_stock,self.store_id)
    end

    kitchen_order_materials.each do |om|
      material_id = om[0]
      date = om[1]
      material = kitchen_materials_hash[material_id]
      stock = Stock.find_by(date:date,material_id:material_id,store_id:39)
      end_day_stock = stock.start_day_stock - stock.used_amount + stock.delivery_amount
      Stock.change_stock(update_stocks,material_id,date,end_day_stock,39)
    end

    Stock.import update_stocks, on_duplicate_key_update:[:end_day_stock,:start_day_stock] if update_stocks.present?
  end

  def reject_material_blank(attributes)
    attributes.merge!(_destroy: "1") if attributes[:material_id].blank?
    # if attributes[:order_quantity]==0 || attributes[:order_quantity]==''
    #   attributes[:un_order_flag] = true
    # end
  end

  def self.fax_send_check
    # imapに接続
    imap_host = 'imap.gmail.com' # imapをgmailのhostに設定する
    imap_usessl = true # imapのsslを有効にする
    imap_port = 993 # ssl有効なら993、そうでなければ143
    imap = Net::IMAP.new(imap_host, imap_port, imap_usessl)
    # imapにログイン
    imap_user = 'masahiro11g@gmail.com'
    imap_passwd = ENV['MASAHIRO_MAIL_PASS']

    imap.login(imap_user, imap_passwd)
    search_criterias = [
      'FROM','no-reply@mail01.lcloud.jp',
      'SINCE', (Date.today-1).strftime("%d-%b-%Y"),
      'UNSEEN'
    ]
    imap.select('INBOX')
    ids = imap.search(search_criterias)
    if ids.present?
      imap.fetch(ids, ["RFC822", "ENVELOPE"]).each do |mail|
        m = Mail.new(mail.attr["RFC822"])
        subject = m.subject.gsub(" ", "").gsub("　","")
        body = m.body.decoded.toutf8
        if subject.include?("【MOVFAX】FAX送信結果")
          recieved_datetime = m.date
          order_id = body[(body.index('(o_id)')+6)..(body.index('(/o_id)')-1)]
          vendor_id = body[(body.index('(v_id)')+6)..(body.index('(/v_id)')-1)]
          result = body[(body.index('[送信結果]')+6)..(body.index('[送信結果]')+6+3)]
          unless FaxMail.find_by(order_id:order_id,vendor_id:vendor_id,recieved:recieved_datetime).present?
            @fax_mail = FaxMail.new
            @fax_mail.subject = subject
            @fax_mail.recieved = recieved_datetime
            order = Order.find(order_id)
            if order.present? && vendor_id.present?
              @fax_mail.order_id = order_id
              @fax_mail.vendor_id = vendor_id
              vendor = Vendor.find(vendor_id)
              order_materials = order.order_materials.where(un_order_flag:false).joins(:material).where(:materials => {vendor_id:vendor_id})
              if result == "正常終了"
                Slack::Notifier.new("https://hooks.slack.com/services/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", username: '監視君', icon_emoji: ':sunglasses:').ping("【送信OK】ID：#{order_id} 発注先：#{vendor.company_name} 担当：#{order.staff_name}")
                # Slack::Notifier.new("https://hooks.slack.com/services/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", username: '監視君', icon_emoji: ':sunglasses:').ping("【送信OK】ID：#{order_id} 発注先：#{vendor.company_name} 担当：#{order.staff_name}")
                order_materials.update_all(status:1)
                @fax_mail.status = 1
              else
                order_materials.update_all(status:2)
                Slack::Notifier.new("https://hooks.slack.com/services/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", username: '天狗様', icon_emoji: ':japanese_goblin:').ping("@channel 【失敗！！】ID：#{order_id} 発注先：#{vendor.company_name} 担当：#{order.staff_name}")
                # Slack::Notifier.new("https://hooks.slack.com/services/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", username: '天狗様', icon_emoji: ':japanese_goblin:').ping("@channel 【失敗！！】ID：#{order_id} 発注先：#{vendor.company_name} 担当：#{order.staff_name}")
                @fax_mail.status = 0
              end
              @fax_mail.save
            end
          end
        end
      end
    end
    imap.logout
  end


end
