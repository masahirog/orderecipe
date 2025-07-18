class Vendor < ApplicationRecord
  has_many :materials
  belongs_to :group
  validates :zip, allow_blank: true, format: {with: /\A\d{3}[-]\d{4}\z|\A\d{7}\z/}
  validates :company_phone, allow_blank: true, format: {with: /\A\d{3}[-]\d{4}[-]\d{4}\z|\A\d{2}[-]\d{4}[-]\d{4}\z|\A\d{11}\z|\A\d{10}\z/}
  validates :company_mail, allow_blank: true, format: {with: /\A\S+@\S+\.\S+\z/}
  validates :company_fax, allow_blank: true, format: {with: /\A\d{3}[-]\d{4}[-]\d{4}\z|\A\d{2}[-]\d{4}[-]\d{4}\z|\A\d{11}\z|\A\d{10}\z/}
  validates :staff_phone, allow_blank: true, format: {with: /\A\d{3}[-]\d{4}[-]\d{4}\z|\A\d{2}[-]\d{4}[-]\d{4}\z|\A\d{11}\z|\A\d{10}\z/}
  validates :staff_mail, allow_blank: true, format: {with: /\A\S+@\S+\.\S+\z/}
  enum status: {非表示:0, 表示:1}

  def self.vendor_index(params)
    hoge = []
    order = Order.find(params[:id])
    order_materials = OrderMaterial.includes(material:[:vendor]).where(order_id:order.id,un_order_flag:false)
    order_materials.each do |om|
      vendor = om.material.vendor
      hash={}
      hash.store("vendor_id", om.material.vendor_id)
      hash.store("company_name", om.material.vendor.name)
      hash.store("company_fax", om.material.vendor.company_fax)
      hoge << hash
    end
    hoge.uniq!
    return hoge
  end

  def self.vendor_fax_index(params)
    hoge = []
    order = Order.find(params[:id])
    order_materials = OrderMaterial.includes(material:[:vendor]).where(order_id:order.id,un_order_flag:false)
    order_materials.each do |om|
      vendor = om.material.vendor
      if vendor.company_fax.present?
        hash={}
        hash.store("vendor_id", om.material.vendor_id)
        hash.store("company_name", om.material.vendor.name)
        hash.store("company_fax", om.material.vendor.company_fax)
        hoge << hash
      end
    end
    hoge.uniq!
    return hoge
  end
  def self.vendor_mail_index(params)
    hoge = []
    order = Order.find(params[:id])
    order_materials = OrderMaterial.includes(material:[:vendor]).where(order_id:order.id,un_order_flag:false)
    order_materials.each do |om|
      vendor = om.material.vendor
      if vendor.company_mail.present?
        hash={}
        hash.store("vendor_id", om.material.vendor_id)
        hash.store("company_name", om.material.vendor.name)
        hash.store("company_mail", om.material.vendor.company_mail)
        hoge << hash
      end
    end
    hoge.uniq!
    return hoge
  end

end
