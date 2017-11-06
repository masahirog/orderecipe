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
    @menu = Menu.new
    @menu.menu_materials.build
  end

  def create
    @menu = Menu.create(menu_create_update)
     if @menu.save
       redirect_to @menu,
       notice: "
       <div class='alert alert-success' role='alert' style='font-size:15px;'>「#{@menu.name}」を作成しました： #{revert_link_menu}
       　　続けてメニューを作成する：<a href='/menus/new'>新規作成</a></div>".html_safe
     else
       render 'new'
     end
  end

  def edit
    if request.referer.include?("products")
      @back_to = request.referer
    end
    @menu = Menu.find(params[:id])
    @menu.menu_materials.build  if @menu.materials.length == 0
  end

  def update
    @menu = Menu.find(params[:id])
    @menu.update(menu_create_update)

    if @menu.save
      if params["menu"]["back_to"].blank?
        redirect_to menu_path, notice: "
        <div class='alert alert-success' role='alert' style='font-size:15px;'>「#{@menu.name}」を更新しました： #{revert_link_menu}
        　　続けてメニューを作成する：<a href='/menus/new'>新規作成</a></div>".html_safe

      else
        redirect_to params["menu"]["back_to"], notice: "
        <div class='alert alert-success' role='alert' style='font-size:15px;'>「#{@menu.name}」を更新しました： #{revert_link_menu}".html_safe
      end
    else
      render "edit"
    end
  end

  def show
    @menu = Menu.find(params[:id])
    @menu_materials = @menu.menu_materials
  end

  def include_menu
    @product_menus = ProductMenu.where(menu_id: params[:id]).page(params[:page]).per(20)
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
      params.require(:menu).permit(:name, :recipe, :category, :recipe, :serving_memo, :cost_price,
                                     menu_materials_attributes: [:id, :amount_used, :menu_id, :material_id, :_destroy,:preparation,:post,
                                     material_attributes:[:name, ]])
    end
end
