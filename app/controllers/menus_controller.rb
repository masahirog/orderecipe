class MenusController < ApplicationController
  def typeahead_action
    render json: Material.where(Material.arel_table[:name].matches("%#{params[:term]}%"))
  end

  def get_cost_price
    @material = Material.includes(:vendor).find(params[:id])
    respond_to do |format|
      format.html
      format.json
    end
  end

  def material_search
    # ("(id = ?) OR (id = ?)", 11, 12)
    @materials = Material.where(end_of_sales: 0).where('name LIKE(?)', "%#{params[:keyword]}%") #paramsとして送られてきたkeyword（入力された語句）で、Userモデルのnameカラムを検索し、その結果を@usersに代入する
    respond_to do |format|
      format.json { render 'index', json: @materials } #json形式のデータを受け取ったら、@materialsをデータとして返す そしてindexをrenderで表示する
    end
  end

  def material_exist
    @material = Material.includes(:vendor).where(end_of_sales: 0).find_by(name:params[:keyword])
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
       redirect_to menus_path
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
      redirect_to menus_path
    else
      render "edit"
    end
  end

  def show
    @menu = Menu.find(params[:id])
    @menu_materials = @menu.menu_materials
    @materials = @menu.materials
  end

  private

    def menu_create_update
      params.require(:menu).permit(:name, :recipe, :category, :recipe, :serving_memo, :cost_price,
                                     menu_materials_attributes: [:id, :amount_used, :menu_id, :material_id, :_destroy,
                                     material_attributes:[:name, ]])
    end
end
