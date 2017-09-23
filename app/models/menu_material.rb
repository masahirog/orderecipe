class MenuMaterial < ApplicationRecord
  belongs_to :menu
  belongs_to :material

  validates :amount_used, presence: true, format: { :with=>/\A\d+(\.)?+(\d){0,3}\z/,
    message: "：小数点3位までの値が入力できます" } #小数点2位までを許容

end
