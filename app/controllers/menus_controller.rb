class MenusController < ApplicationController
  def get_cost_price
    @material = Material.includes(:vendor).find(params[:id])
    respond_to do |format|
      format.html
      format.json
    end
  end

  def index
    @search = Menu.search(params).page(params[:page]).per(20)
  end

  def new
    @food_ingredients = FoodIngredient.all
    @materials = Material.where(unused_flag:false)
    if params[:copy_flag]=='true'
      original_menu = Menu.includes(:menu_materials,{materials:[material_food_additives:[:food_additive]]}).find(params[:menu_id])
      original_menu.menu_materials = original_menu.menu_materials.each{|menu_material|menu_material.amount_used = (menu_material.amount_used * params[:used_rate].to_f).round(2)}
      @menu = original_menu.deep_clone(include: [:menu_materials])
      @menu.name = "#{original_menu.name}のコピー"
      @menu.base_menu_id = original_menu.id
      @base_menu = original_menu
      @ar = Menu.used_additives(original_menu.materials)
    else
      @menu = Menu.new
      @menu.menu_materials.build(row_order: 0)
      @ar = Menu.used_additives(@menu.materials)
    end
  end

  def create
    @food_ingredients = FoodIngredient.all
    @materials = Material.where(unused_flag:false)
    @menu = Menu.new(menu_create_update)
     if @menu.save
       redirect_to @menu,
       notice: "「#{@menu.name}」を作成しました。続けてメニューを作成する：<a href='/menus/new'>新規作成</a>".html_safe
     else
       @ar = Menu.used_additives(@menu.materials)
       render 'new'
     end
  end

  def edit
    if request.referer.nil?
    elsif request.referer.include?("products")
      @back_to = request.referer
    end
    @menu = Menu.includes(:menu_materials,{materials:[:vendor,material_food_additives:[:food_additive]]}).find(params[:id])
    @base_menu = Menu.find(@menu.base_menu_id) unless @menu.base_menu_id == @menu.id
    @materials = Material.where(unused_flag:false)
    @food_ingredients = FoodIngredient.all
    @menu.menu_materials.build  if @menu.materials.length == 0
    @ar = Menu.used_additives(@menu.materials)
  end
  def update
    @food_ingredients = FoodIngredient.all
    @materials = Material.where(unused_flag:false)
    @menu = Menu.includes(:menu_materials,{materials:[:vendor,:material_food_additives]}).find(params[:id])
    if @menu.update(menu_create_update)
      if params["menu"]["back_to"].blank?
        redirect_to menu_path, notice: "「#{@menu.name}」を更新しました。続けてメニューを作成する：<a href='/menus/new'>新規作成</a>".html_safe

      else
        redirect_to params["menu"]["back_to"], notice: "「#{@menu.name}」を更新しました".html_safe
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
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "#{Time.now.strftime('%Y%m%d')}_menu_#{@menu.id}.csv", type: :csv
      end
    end
  end

  def print
    @menu = Menu.includes(menu_materials: :material).find(params[:id])
    @menu_materials = @menu.menu_materials
    respond_to do |format|
     format.html
     format.pdf do
       pdf = MenuPdf.new(@menu,@menu_materials)
       send_data pdf.render,
         filename:    "#{@menu.name}.pdf",
         type:        "application/pdf",
         disposition: "inline"
     end
   end
  end

  def include_menu
    @product_menus = ProductMenu.includes(:product).where(menu_id: params[:id]).page(params[:page]).per(20)
    @menus = Menu.all
  end
  def include_update
    update_pms = params[:post]
    update_pms.each do |pm|
      @pm = ProductMenu.find(pm[:pm_id])
      @pm.update_attribute(:menu_id, pm[:menu_id])
    end
    menu_id = params[:menu_id]
    redirect_to include_menu_menus_path(id:menu_id), notice: "メニューを変更しました。"
  end

  def get_food_ingredient
    gram_amount = params[:gram_amount].to_f
    id = params[:id]
    @index = params[:index]
    @calculated_nutrition = FoodIngredient.calculate_nutrition(gram_amount,id)
    respond_to do |format|
      format.json{render :json =>[@index,@calculated_nutrition[0],@calculated_nutrition[1]] }
    end
  end
  def food_ingredient_search
    respond_to do |format|
      format.json { render json: @materials = FoodIngredient.food_ingredient_search(params[:q]) }
    end
  end

  private

    def menu_create_update
      params.require(:menu).permit({used_additives:[]},:name, :recipe, :category, :recipe, :serving_memo, :cost_price,:food_label_name,:confirm_flag,:taste_description, :image,:base_menu_id,
                                    :remove_image, :image_cache,menu_materials_attributes: [:id, :amount_used, :material_id, :_destroy,:preparation,:post,:base_menu_material_id,
                                     :row_order,:gram_quantity,:food_ingredient_id,:calorie,:protein,:lipid,:carbohydrate,:dietary_fiber,
                                     :potassium,:calcium,:vitamin_b1,:vitamin_b2,:vitamin_c,:salt,:magnesium,:iron,:zinc,:copper,:folic_acid,:vitamin_d])
    end
end
