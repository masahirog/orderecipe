class MenuMaterial < ApplicationRecord
  belongs_to :menu, optional: true
  belongs_to :material
  belongs_to :food_ingredient, optional: true

  validates :amount_used, presence: true, format: { :with=>/\A\d+(\.)?+(\d){0,3}\z/,
    message: "：小数点3位までの値が入力できます" }, numericality: true
  validates :material_id, presence: true
  before_destroy :copy_delete
  enum source_group: { A:1,B:2,C:3,D:4,E:5,F:6,G:7,H:8}
  enum post: {'なし':0,'調理場':1,'切出し':2,'切出/調理':3,'切出/スチコン':4,'タレ':5}
  def copy_delete
    MenuMaterial.where.not(id:self.id).where(base_menu_material_id:self.id).destroy_all
  end
end
