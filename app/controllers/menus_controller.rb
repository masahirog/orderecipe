class MenusController < ApplicationController
  # before_action :set_menu, only: [:edit, :show, :update]
  def index
    @search = Menu.search(params).page(params[:page]).per(20)
    @menus = Menu.all

  end
  def new
    @menu = Menu.new
    @menu.menu_materials.build
  end
  def create
    Menu.create(menu_params)
    redirect_to menus_path
  end
  def edit
    @menu = Menu.find(params[:id])
    @menu.menu_materials.build
  end

  def update
    menu = Menu.find(params[:id])
    menu.update(menu_params2)
  end
  def show
    @menu = Menu.find(params[:id])
    @menu_materials = @menu.menu_materials
    @materials = @menu.materials
  end

  private

    def menu_params
      params.require(:menu).permit(:name, :recipe,
                                     menu_materials_attributes: [:id, :amount_used, :cost_price, :menu_id, :material_id, :_destroy,
                                     material_attributes:[:name, ]])
    end
    def menu_params2
     params.permit(:name, :recipe,
                                    menu_materials_attributes: [:id, :amount_used, :cost_price, :menu_id, :material_id, :_destroy,
                                    material_attributes:[:name, ]])
    end
end
