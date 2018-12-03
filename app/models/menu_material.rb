class MenuMaterial < ApplicationRecord
  has_paper_trail

  belongs_to :menu
  belongs_to :material
  belongs_to :food_ingredient, optional: true

  validates :amount_used, presence: true, format: { :with=>/\A\d+(\.)?+(\d){0,3}\z/,
    message: "：小数点3位までの値が入力できます" }, numericality: true
  validates :material_id, presence: true

end
