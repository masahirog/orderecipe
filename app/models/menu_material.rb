class MenuMaterial < ApplicationRecord
  has_paper_trail

  belongs_to :menu, optional: true
  belongs_to :material
  belongs_to :food_ingredient, optional: true

  validates :amount_used, presence: true, format: { :with=>/\A\d+(\.)?+(\d){0,3}\z/,
    message: "：小数点3位までの値が入力できます" }, numericality: true
  validates :material_id, presence: true
  before_destroy :copy_delete
  after_create :base_mm_id

  def copy_delete
    MenuMaterial.where.not(id:self.id).where(base_menu_material_id:self.id).destroy_all
  end
  def base_mm_id
    unless self.base_menu_material_id.present?
      self.update_column(:base_menu_material_id, self.id)
    end
  end
end
