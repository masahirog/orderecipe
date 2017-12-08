class MaterialsController < ApplicationController
  def index
    @search = Material.search(params).includes(:vendor).page(params[:page]).per(20)
  end

  def new
    @material = Material.new
  end

  def create
    @material = Material.create(material_params)
       if @material.save
         redirect_to @material, notice: "
         <div class='alert alert-success' role='alert' style='font-size:15px;'>「#{@material.name}」を作成しました： #{revert_link}
         　　続けて食材を作成する：<a href='/materials/new'>新規作成</a></div>".html_safe
       else
         render 'new'
       end
  end
  def show
    @material = Material.find(params[:id])
  end

  def edit
    if request.referer.include?("products")
      @back_to = request.referer
    elsif request.referer.include?("menus")
      @back_to = request.referer
    end
    @material = Material.find(params[:id])
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
    @menu_materials = MenuMaterial.where(material_id: params[:id]).page(params[:page]).per(20)
    @materials = Material.all
  end
  def include_update
    update_mms = params[:post]
    update_mms.each do |mm|
      @mm = MenuMaterial.find(mm[:mm_id])
      @mm.update_attribute(:material_id, mm[:material_id])
    end
    redirect_to :back
  end

  private
  def material_params
    params.require(:material).permit(:name, :order_name, :calculated_value, :calculated_unit,
     :calculated_price, :cost_price, :category, :order_code, :order_unit, :memo, :end_of_sales, :vendor_id,:order_unit_quantity)
  end

end
