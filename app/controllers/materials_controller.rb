class MaterialsController < ApplicationController
  protect_from_forgery :except => [:change_additives]
  def index
    @search = Material.search(params).includes(:vendor).page(params[:page]).per(30)
  end

  def new
    @material = Material.new
    @material.material_food_additives.build
    @food_additive = FoodAdditive.new
    @storage_locations = StorageLocation.all
  end

  def create
    @material = Material.create(material_params)
       if @material.save
         redirect_to @material, notice: "
         <div class='alert alert-success' role='alert' style='font-size:15px;'>「#{@material.name}」を作成しました：
         　　続けて食材を作成する：<a href='/materials/new'>新規作成</a></div>".html_safe
       else
         render 'new'
       end
  end
  def show
    @material = Material.find(params[:id])
  end

  def edit
    if request.referer.nil?
    elsif request.referer.include?("products")
      @back_to = request.referer
    elsif request.referer.include?("menus")
      @back_to = request.referer
    end
    @material = Material.find(params[:id])
    @material.material_food_additives.build if @material.material_food_additives.length == 0
    @food_additive = FoodAdditive.new
    @storage_locations = StorageLocation.all
  end

  def update
    @material = Material.find(params[:id])
    @material.update(material_params)
    if @material.save
        redirect_to material_path, notice: "
        <div class='alert alert-success' role='alert' style='font-size:15px;'>
        「#{@material.name}」を更新しました。
        　　続けて食材を作成する：<a href='/materials/new'>新規作成</a></div>".html_safe

    else
      render 'edit'
    end
  end

  def include_material
    @menu_materials = MenuMaterial.includes(:material,:menu).where(material_id: params[:id]).page(params[:page]).per(20)
    @materials = Material.all
  end
  def include_update
    update_mms = params[:post]
    update_mms.each do |mm|
      @mm = MenuMaterial.find(mm[:mm_id])
      @mm.update_attribute(:material_id, mm[:material_id])
    end
     material_id = params[:material_id]
     redirect_to "/materials/include_material/#{material_id}", notice: "食材を変更しました。"
  end

  def change_additives
    @ar = Material.change_additives(params[:data])
    respond_to do |format|
      format.html
      format.json{render :json => @ar}
    end
  end

  def search
    respond_to do |format|
      format.json { render json: @materials = Material.mate_search(params[:q]) }
    end
  end

  private
  def material_params
    params.require(:material).permit(:name, :order_name, :calculated_value, :calculated_unit,:vegetable_flag,:vendor_stock_flag,:storage_location_id,
     :calculated_price, :cost_price, :category, :order_code, :order_unit, :memo, :end_of_sales, :vendor_id,:order_unit_quantity,:delivery_deadline,
     {allergy:[]},material_food_additives_attributes:[:id,:material_id,:food_additive_id,:_destroy])
  end
end
