class MenusController < ApplicationController
  def get_cost_price
    @material = Material.includes(:vendor).find(params[:id])
    @food_ingredient = @material.food_ingredient
    respond_to do |format|
      format.html
      format.json
    end
  end
  def get_material
    @materials = Material.where(group_id:current_user.group_id,unused_flag:false).where("name LIKE ?", "%#{params[:q]}%").first(20)
    @materials = @materials.map{|material|[material.id,"#{material.name}｜#{material.vendor.name}"]}
    respond_to do |format|
      format.json { render json: @materials }
    end
  end


  def index
    @search = Menu.includes(:product_menus).search(params,current_user.group_id).page(params[:page]).per(20)
  end

  def new
    @range = 80.times.map { |i| i * 5 }
    # @food_ingredients = FoodIngredient.all
    @food_ingredients = []
    @materials = []
    if params[:copy_flag]=='true'
      original_menu = Menu.includes(:menu_materials,{materials:[material_food_additives:[:food_additive]]}).find(params[:menu_id])
      original_menu.menu_materials = original_menu.menu_materials.each{|menu_material|menu_material.amount_used = (menu_material.amount_used * params[:used_rate].to_f).round(2)}
      @menu = original_menu.deep_clone(include: [:menu_materials])
      @menu.name = "#{original_menu.name}のコピー"
      @menu.base_menu_id = original_menu.id
      @base_menu = original_menu
      @ar = Menu.used_additives(original_menu.materials)
    elsif params[:original_menu_id].present?
      origin_menu = Menu.find(params[:original_menu_id])
      @menu = origin_menu.deep_clone(include: [:menu_materials], except: [{ menu_materials: [:base_menu_material_id]}])
      @menu.base_menu_id = nil
      @ar = Menu.used_additives(@menu.materials)
      @materials = origin_menu.materials
    else
      @menu = Menu.new
      @menu.menu_materials.build(row_order: 0)
      @ar = Menu.used_additives(@menu.materials)
    end
    @origin_food_label_contents = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @menu.menu_materials.where.not(material_id:1).each do |mm|
      if @origin_food_label_contents[mm.material_id].present?
        @origin_food_label_contents[mm.material_id][:amount] += mm.gram_quantity
      else
        @origin_food_label_contents[mm.material_id][:amount] = mm.gram_quantity
        @origin_food_label_contents[mm.material_id][:material] = mm.material
      end
    end
    @data = @origin_food_label_contents.sort{|a, b|b[1][:amount] <=> a[1][:amount]}.map{|data| data[1][:material].food_label_name}
  end

  def create
    @range = 80.times.map { |i| i * 5 }
    @food_ingredients = FoodIngredient.all
    # @materials = Material.where(unused_flag:false)
    @menu = Menu.new(menu_create_update)
    @materials = Material.where(id:@menu.menu_materials.map{|mm|mm.material_id})
    # @materials = @menu.materials
    if @menu.save
     redirect_to @menu,
     success: "「#{@menu.name}」を作成しました。続けてメニューを作成する：<a href='/menus/new'>新規作成</a>".html_safe
    else
     @ar = Menu.used_additives(@menu.materials)
     render 'new'
    end
  end

  def edit
    @range = 80.times.map { |i| i * 5 }
    if request.referer.nil?
    elsif request.referer.include?("products")
      @back_to = request.referer
    end
    @menu = Menu.includes({materials:[:material_cut_patterns,:food_ingredient,:vendor,material_food_additives:[:food_additive]]}).find(params[:id])
    @base_menu = Menu.find(@menu.base_menu_id) unless @menu.base_menu_id == @menu.id
    @materials = @menu.materials
    @food_ingredients = @menu.food_ingredients
    @menu.menu_materials.build  if @menu.materials.length == 0
    @ar = Menu.used_additives(@menu.materials)
    @origin_food_label_contents = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @menu.menu_materials.where.not(material_id:1).each do |mm|
      if @origin_food_label_contents[mm.material_id].present?
        @origin_food_label_contents[mm.material_id][:amount] += mm.gram_quantity
      else
        @origin_food_label_contents[mm.material_id][:amount] = mm.gram_quantity
        @origin_food_label_contents[mm.material_id][:material] = mm.material
      end
    end
    @data = @origin_food_label_contents.sort{|a, b|b[1][:amount] <=> a[1][:amount]}.map{|data| data[1][:material].food_label_name}
  end
  def update
    @range = 80.times.map { |i| i * 5 }
    @food_ingredients = FoodIngredient.all
    @menu = Menu.includes(:menu_materials,{materials:[:vendor,:material_food_additives]}).find(params[:id])
    @materials = @menu.materials

    if @menu.update(menu_create_update)
      if params["menu"]["back_to"].blank?
        redirect_to menu_path, success: "「#{@menu.name}」を更新しました。続けてメニューを作成する：<a href='/menus/new'>新規作成</a>".html_safe

      else
        redirect_to params["menu"]["back_to"], success: "「#{@menu.name}」を更新しました".html_safe
      end
    else
      @ar = Menu.used_additives(@menu.materials)
      render "edit"
    end
  end

  def show
    @menu = Menu.includes(:menu_materials,{materials: [:vendor]}).find(params[:id])
    @food_additives = FoodAdditive.where(id:@menu.used_additives)
    @arr = Menu.allergy_seiri(@menu)
    @base_menu = Menu.find(@menu.base_menu_id) unless @menu.base_menu_id == @menu.id
    product_menus = @menu.product_menus
    copy_menus = Menu.where(base_menu_id:@menu.id).where.not(id:@menu.id)
    unless product_menus.present? || copy_menus.present?
      @delete_flag = true
    end

    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "#{Time.now.strftime('%Y%m%d')}_menu_#{@menu.id}.csv", type: :csv
      end
    end
  end

  def print
    num = params[:num].to_i
    @menu = Menu.includes(menu_materials: :material).find(params[:id])
    @menu_materials = @menu.menu_materials
    respond_to do |format|
     format.html
     format.pdf do
       pdf = MenuPdf.new(@menu,@menu_materials,num)
       send_data pdf.render,
         filename:    "#{@menu.name}.pdf",
         type:        "application/pdf",
         disposition: "inline"
     end
   end
  end


  def include_update
    update_pms = params[:post]
    update_pms.each do |pm|
      @pm = ProductMenu.find(pm[:pm_id])
      @pm.update_attribute(:menu_id, pm[:menu_id])
    end
    menu_id = params[:menu_id]
    redirect_to include_menu_menus_path(id:menu_id), success: "メニューを変更しました。"
  end

  # def get_food_ingredient
  #   gram_amount = params[:gram_amount].to_f
  #   id = params[:id]
  #   @index = params[:index]
  #   @calculated_nutrition = FoodIngredient.calculate_nutrition(gram_amount,id)
  #   respond_to do |format|
  #     format.json{render :json =>[@index,@calculated_nutrition[0],@calculated_nutrition[1]] }
  #   end
  # end
  def food_ingredient_search
    respond_to do |format|
      format.json { render json: @materials = FoodIngredient.food_ingredient_search(params[:q]) }
    end
  end

  def destroy
    @menu = Menu.find(params[:id])
    @menu.destroy
    respond_to do |format|
      format.html { redirect_to menus_path, success: '1件メニューを削除しました。' }
      format.json { head :no_content }
    end
  end

  private

    def menu_create_update
      params.require(:menu).permit({used_additives:[]},:name,:roma_name, :cook_the_day_before, :category, :serving_memo, :cost_price,:cook_on_the_day,:food_label_name,
        :food_label_contents,:image,:base_menu_id,:short_name,:remove_image, :image_cache,:group_id,:calorie,:protein,:lipid,:carbohydrate,:dietary_fiber,:salt,:seibun_keisan_done_flag,
        menu_materials_attributes: [:id, :amount_used, :material_id, :_destroy,:preparation,:post,:base_menu_material_id,:source_flag,
        :row_order,:gram_quantity,:calorie,:protein,:lipid,:carbohydrate,:dietary_fiber,
        :salt,:source_group,:first_flag,:machine_flag,:material_cut_pattern_id],
        menu_last_processes_attributes:[:id,:menu_id,:content,:memo,:_destroy],menu_cook_checks_attributes:[:id,:menu_id,:content,:_destroy,:check_position],
        menu_processes_attributes:[:id,:menu_id,:image,:memo,:image_cache,:remove_image,:_destroy])
    end
end
