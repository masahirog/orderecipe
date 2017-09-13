class Vendor < ApplicationRecord
  has_many :materials

  validates :company_name, presence: true, uniqueness: true
  validates :zip, allow_blank: true, format: {with: /\A\d{3}[-]\d{4}\z|\A\d{7}\z/}
  validates :company_phone, allow_blank: true, format: {with: /\A\d{3}[-]\d{4}[-]\d{4}\z|\A\d{2}[-]\d{4}[-]\d{4}\z|\A\d{11}\z|\A\d{10}\z/}
  validates :company_mail, allow_blank: true, format: {with: /\A\S+@\S+\.\S+\z/}
  validates :company_fax, allow_blank: true, format: {with: /\A\d{3}[-]\d{4}[-]\d{4}\z|\A\d{2}[-]\d{4}[-]\d{4}\z|\A\d{11}\z|\A\d{10}\z/}
  validates :staff_phone, allow_blank: true, format: {with: /\A\d{3}[-]\d{4}[-]\d{4}\z|\A\d{2}[-]\d{4}[-]\d{4}\z|\A\d{11}\z|\A\d{10}\z/}
  validates :staff_mail, allow_blank: true, format: {with: /\A\S+@\S+\.\S+\z/}

end
