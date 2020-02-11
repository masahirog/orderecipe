class Menu < ApplicationRecord
  mount_uploader :image, ImageUploader
  serialize :used_additives
  has_many :menu_materials,->{order("row_order asc") }, dependent: :destroy
  has_many :materials, through: :menu_materials
  accepts_nested_attributes_for :menu_materials, allow_destroy: true
  has_many :product_menus, dependent: :destroy
  has_many :products, through: :product_menus

  # after_update :update_product_cost_price

  validates :name, presence: true, uniqueness: true, format: { with:/\A[^０-９ａ-ｚＡ-Ｚ]+\z/,
    message: "：全角英数字は使用出来ません。"}
  validates :category, presence: true
  validates :cost_price, presence: true, numericality: true
  validates :food_label_name, presence: true, format: { with:/\A[^０-９ａ-ｚＡ-Ｚ]+\z/,
    message: "：全角英数字は使用出来ません。"}
  after_create :base_menu_id_check
  after_update :copy_menu_reflect

  enum category: {主食:1,主菜:2,副菜:3,容器:4}
  def self.search(params)
   if params
     data = Menu.order(id: "DESC").all
     data = data.where(['name LIKE ?', "%#{params["name"]}%"]) if params["name"].present?
     data = data.where(category: params["category"]) if params["category"].present?
     data = data.where(confirm_flag: params["confirm_flag"]) if params["confirm_flag"].present?
     data = data.where(base_menu_id: params["base_menu_id"]) if params["base_menu_id"].present?
     data = data.reorder(params['order']) if params["order"].present?
     data
   else
     Menu.order(id: "DESC").all
   end
  end


  def self.menu_materials_info(params)
    menu = Menu.includes(:menu_materials,:materials).find(params[:id])
    hoge = []
    menu.menu_materials.each do |mm|
      hash = {}
      hash.store("material_name", mm.material.name)
      hash.store("material_cost_price", mm.material.cost_price)
      hash.store("amount_used", mm.amount_used)
      hash.store("recipe_unit", mm.material.recipe_unit)
      hash.store("preparation", mm.preparation)
      hoge << hash
    end
    return hoge
  end

  def self.used_additives(materials)
    ar =[]
    materials.each do |material|
      arr=[]
      if material.material_food_additives.present?
        material.material_food_additives.each do |material_food_additive|
          arr << [material_food_additive.food_additive.name,material_food_additive.food_additive_id]
        end
        ar << [material.name,arr]
      else
      end
    end
    @ar = ar
  end

  def self.allergy_seiri(menu)
    arr=[]
    menu.materials.each do |mate|
      arr << mate.allergy
    end
    @arr = arr.flatten.uniq
    @arr.delete("")
    @arr.delete("0")
    @arr.delete(0)
    allergy = {"egg"=>"卵","milk"=>"乳","shrimp"=>"えび","crab"=>"かに","peanuts"=>"落花生","soba"=>"そば","wheat"=>"小麦"}
    @arr = @arr.map{|ar| allergy[ar]}
  end
  def base_menu_id_check
    self.update_column(:base_menu_id, self.id) unless self.base_menu_id.present?
    self.menu_materials.each do |mm|
      unless mm.base_menu_material_id.present?
        mm.update_column(:base_menu_material_id, mm.id)
      end
    end
  end
  def copy_menu_reflect
    self.menu_materials.each do |mm|
      # material_idがチェンジしていたら
      if mm.saved_change_to_material_id?
        material_id = mm.material_id
        bmi = mm.base_menu_material_id
        MenuMaterial.where(base_menu_material_id:bmi).update_all(material_id:material_id)
      end
      unless mm.base_menu_material_id.present?
        mm.update_column(:base_menu_material_id,mm.id)
        original_menu_material = mm.clone
        menu_ids =  Menu.where.not(id:self.id).where(base_menu_id:self.id).ids
        menu_ids.each do |id|
          new_menu_material = mm.dup
          new_menu_material.menu_id = id
          new_menu_material.save
        end
      end
    end
  end
  private
end
