class MenusController < ApplicationController
  def get_cost_price
    @material = Material.includes(:vendor).find(params[:id])
    respond_to do |format|
      format.html
      format.json
    end
  end

  def index
    @search = Menu.includes(:menu_materials,:materials).search(params).page(params[:page]).per(20)
  end

  def new
    @menu = Menu.new
    @menu.menu_materials.build(row_order: 0)
    @ar = Menu.used_additives(@menu.materials)
  end

  def create
    @menu = Menu.create(menu_create_update)
     if @menu.save
       redirect_to @menu,
       notice: "
       <div class='alert alert-success' role='alert' style='font-size:15px;'>「#{@menu.name}」を作成しました
       　　続けてメニューを作成する：<a href='/menus/new'>新規作成</a></div>".html_safe
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
    @menu = Menu.includes(:menu_materials,{materials:[:vendor,:material_food_additives]}).find(params[:id])
    @menu.menu_materials.build  if @menu.materials.length == 0
    @ar = Menu.used_additives(@menu.materials.includes(:food_additives))
  end
  def update
    @menu = Menu.find(params[:id])
    @menu.update(menu_create_update)
    if @menu.save
      if params["menu"]["back_to"].blank?
        redirect_to menu_path, notice: "
        <div class='alert alert-success' role='alert' style='font-size:15px;'>「#{@menu.name}」を更新しました：
        　　続けてメニューを作成する：<a href='/menus/new'>新規作成</a></div>".html_safe

      else
        redirect_to params["menu"]["back_to"], notice: "
        <div class='alert alert-success' role='alert' style='font-size:15px;'>「#{@menu.name}」を更新しました：".html_safe
      end
    else
      @ar = Menu.used_additives(@menu.materials)
      render "edit"
    end
  end

  def show
    @menu = Menu.includes(:menu_materials,{materials: [:vendor]}).find(params[:id])
    @arr = Menu.allergy_seiri(@menu)
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
    redirect_to :back
  end

  private

    def menu_create_update
      params.require(:menu).permit({used_additives:[]},:name, :recipe, :category, :recipe, :serving_memo, :cost_price,:food_label_name,
                                     menu_materials_attributes: [:id, :amount_used, :menu_id, :material_id, :_destroy,:preparation,:post,
                                     :row_order,material_attributes:[:name, ]])
    end
end
