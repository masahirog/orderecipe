class Vendor < ApplicationRecord
  has_many :materials
  validates :company_name, presence: true, uniqueness: true
  validates :zip, allow_blank: true, format: {with: /\A\d{3}[-]\d{4}\z|\A\d{7}\z/}
  validates :company_phone, allow_blank: true, format: {with: /\A\d{3}[-]\d{4}[-]\d{4}\z|\A\d{2}[-]\d{4}[-]\d{4}\z|\A\d{11}\z|\A\d{10}\z/}
  validates :company_mail, allow_blank: true, format: {with: /\A\S+@\S+\.\S+\z/}
  validates :company_fax, allow_blank: true, format: {with: /\A\d{3}[-]\d{4}[-]\d{4}\z|\A\d{2}[-]\d{4}[-]\d{4}\z|\A\d{11}\z|\A\d{10}\z/}
  validates :staff_phone, allow_blank: true, format: {with: /\A\d{3}[-]\d{4}[-]\d{4}\z|\A\d{2}[-]\d{4}[-]\d{4}\z|\A\d{11}\z|\A\d{10}\z/}
  validates :staff_mail, allow_blank: true, format: {with: /\A\S+@\S+\.\S+\z/}

  def self.vendor_index(params)
    hoge = []
    order = Order.find(params[:id])
    order_materials = OrderMaterial.includes(material:[:vendor]).where(order_id:order.id,un_order_flag:false)
    order_materials.each do |om|
      hash={}
      hash.store("vendor_id", om.material.vendor_id)
      hash.store("company_name", om.material.vendor.company_name)
      hash.store("company_fax", om.material.vendor.company_fax)
      hash.store("efax_address", om.material.vendor.efax_address)
      hoge << hash
    end
    hoge.uniq!
    return hoge
  end

end
