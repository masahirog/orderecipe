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
         redirect_to materials_path
       else
         render 'new'
       end
  end

  def edit
    @material = Material.find(params[:id])

  end

  def update
    @material = Material.find(params[:id])
    @material.update(material_params)
    if @material.save
      redirect_to materials_path
    else
      render 'edit'
    end
  end

  private
  def material_params
    params.require(:material).permit(:name, :order_name, :calculated_value, :calculated_unit,
     :calculated_price, :cost_price, :category, :order_code, :memo, :end_of_sales, :vendor_id)
  end

end
