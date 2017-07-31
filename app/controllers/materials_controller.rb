class MaterialsController < ApplicationController
  def index
    @search = Material.search(params).page(params[:page]).per(20)
    @materials = Material.page(params[:page]).per(20)
  end

  def new
    @material = Material.new
  end

  def create
    Material.create(material_params)
    redirect_to materials_path
  end

  def edit
    @material = Material.find(params[:id])

  end

  def update
    material = Material.find(params[:id])
    material.update(material_params2)
  end

  private
  def material_params
    params.require(:material).permit(:name, :delivery_slip_name, :calculated_value, :calculated_unit, :calculated_price, :cost_price, :cost_unit, :category, :vendor, :code, :memo, :status)
  end
  def material_params2
    params.permit(:name, :delivery_slip_name, :calculated_value, :calculated_unit, :calculated_price, :cost_price, :cost_unit, :category, :vendor, :code, :memo, :status)
  end

end
