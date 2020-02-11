class MenuMaterial < ApplicationRecord
  belongs_to :menu, optional: true
  belongs_to :material
  belongs_to :food_ingredient, optional: true

  validates :amount_used, presence: true, format: { :with=>/\A\d+(\.)?+(\d){0,3}\z/,
    message: "：小数点3位までの値が入力できます" }, numericality: true
  validates :material_id, presence: true
  before_destroy :copy_delete

  def copy_delete
    MenuMaterial.where.not(id:self.id).where(base_menu_material_id:self.id).destroy_all
  end
end
