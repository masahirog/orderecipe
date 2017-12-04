class Vendor < ApplicationRecord
  has_paper_trail

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
    order = Order.includes({materials:[:vendor]}).find(params[:id])
    order.materials.each do |om|
      hash={}
      hash.store("vendor_id", om.vendor_id)
      hash.store("company_name", om.vendor.company_name)
      hoge << hash
    end
    hoge.uniq!
    return hoge
  end

end
