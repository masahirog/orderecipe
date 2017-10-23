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
       redirect_to menus_path, notice: "「#{@menu.name}」を作成しました。: #{revert_link_menu}"
     else
       render 'new'
     end
  end

  def edit
    @menu = Menu.find(params[:id])
  end

  def update
    @menu = Menu.find(params[:id])
    @menu.update(menu_create_update)

    if @menu.save
      redirect_to menu_path, notice: "「#{@menu.name}」を更新しました。: #{revert_link_menu}"
    else
      render "edit"
    end
  end

  def show
    @menu = Menu.find(params[:id])
    @menu_materials = @menu.menu_materials
  end

  private

    def menu_create_update
      params.require(:menu).permit(:name, :recipe, :category, :recipe, :serving_memo, :cost_price,
                                     menu_materials_attributes: [:id, :amount_used, :menu_id, :material_id, :_destroy,:preparation,:post,
                                     material_attributes:[:name, ]])
    end
end
