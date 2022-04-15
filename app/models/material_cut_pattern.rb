class MaterialCutPattern < ApplicationRecord
  enum machine: {slicer:1,food_processor:2,mijinger:3}
  belongs_to :material
  has_many :menu_materials
  after_destroy :menu_material_cut_pattern_id_destroy

  def menu_material_cut_pattern_id_destroy
    self.menu_materials.update_all(material_cut_pattern_id:nil)
  end
end
