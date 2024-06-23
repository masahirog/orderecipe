class MenuMaterial < ApplicationRecord
  belongs_to :material_cut_pattern
  belongs_to :menu, optional: true
  belongs_to :material
  belongs_to :food_ingredient, optional: true
  has_many :temporary_menu_materials

  validates :amount_used, presence: true, format: { :with=>/\A\d+(\.)?+(\d){0,3}\z/,
    message: "：小数点3位までの値が入力できます" }, numericality: true
  validates :material_id, presence: true
  before_destroy :copy_delete
  enum source_group: {A:1,B:2,C:3,D:4,E:5,F:6,G:7,H:8}
  enum post: {'なし':0,'調理場':1,'切出し':2,'切出/調理':3,'切出/スチコン':4,'タレ':5}
  def copy_delete
    MenuMaterial.where.not(id:self.id).where(base_menu_material_id:self.id).destroy_all
  end


  def self.seibun
    updates_arr = []
    material_ids = [26469,27539,30679,31269,19791,23691,25871,5811,5831,5911,5961,6211,23961,40481,6051,14021,15261,33304,
    40477,40479,22901,30539,27629,2011,12651,17131,17591,22471,23551,23921,25561,39814,40164,40515,33284,4761,31329,12501,34294]

    MenuMaterial.where(material_id:material_ids,gram_quantity:0).each do |mm|
      mm.gram_quantity = (mm.amount_used * mm.material.recipe_unit_gram_quantity).round(2)
      updates_arr << mm
    end
    MenuMaterial.import updates_arr, on_duplicate_key_update:[:gram_quantity]
    p updates_arr.length
  end


  def self.calculate_seibun
    updates_arr = []
    MenuMaterial.all.each do |mm|
      if mm.gram_quantity > 0
        if mm.material.food_ingredient_id.present?
          food_ingredient = mm.material.food_ingredient
          mm.calorie = (food_ingredient.calorie * mm.gram_quantity).round(2)
          mm.protein = (food_ingredient.protein * mm.gram_quantity).round(2)
          mm.lipid = (food_ingredient.lipid * mm.gram_quantity).round(2)
          mm.carbohydrate = (food_ingredient.carbohydrate * mm.gram_quantity).round(2)
          mm.dietary_fiber = (food_ingredient.dietary_fiber * mm.gram_quantity).round(2)
          mm.salt = (food_ingredient.salt * mm.gram_quantity).round(2)
          updates_arr << mm
        end
      end
    end
    MenuMaterial.import updates_arr, on_duplicate_key_update:[:calorie,:protein,:lipid,:carbohydrate,:dietary_fiber,:salt]
    p updates_arr.length
  end

  def self.update_seibun_menu
    updates_arr = []
    Menu.all.each do |menu|
      menu.calorie = menu.menu_materials.sum(:calorie).round(2)
      menu.protein = menu.menu_materials.sum(:protein).round(2)
      menu.lipid = menu.menu_materials.sum(:lipid).round(2)
      menu.carbohydrate = menu.menu_materials.sum(:carbohydrate).round(2)
      menu.dietary_fiber = menu.menu_materials.sum(:dietary_fiber).round(2)
      menu.salt = menu.menu_materials.sum(:salt).round(2)
      updates_arr << menu
    end
    Menu.import updates_arr, on_duplicate_key_update:[:calorie,:protein,:lipid,:carbohydrate,:dietary_fiber,:salt]
    p updates_arr.length
  end

  def self.update_seibun_product
    updates_arr = []
    Product.all.each do |product|
      product.calorie = product.menus.sum(:calorie).round(2)
      product.protein = product.menus.sum(:protein).round(2)
      product.lipid = product.menus.sum(:lipid).round(2)
      product.carbohydrate = product.menus.sum(:carbohydrate).round(2)
      product.dietary_fiber = product.menus.sum(:dietary_fiber).round(2)
      product.salt = product.menus.sum(:salt).round(2)
      updates_arr << product
    end
    Product.import updates_arr, on_duplicate_key_update:[:calorie,:protein,:lipid,:carbohydrate,:dietary_fiber,:salt]
    p updates_arr.length
  end

end
