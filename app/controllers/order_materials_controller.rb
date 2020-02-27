class OrderMaterialsController < ApplicationController
  before_action :set_order_material, only: [:show, :edit, :update, :destroy]

  def index
    @order_materials = OrderMaterial.all
  end

  def show
  end

  def new
    @order_material = OrderMaterial.new
  end

  def edit
  end

  def create
    @order_material = OrderMaterial.new(order_material_params)

    respond_to do |format|
      if @order_material.save
        format.html { redirect_to @order_material, notice: 'Order material was successfully created.' }
        format.js
      else
        format.html { render :new }
        format.js
      end
    end
  end

  def update
    respond_to do |format|
      if @order_material.update(order_material_params)
        format.html { redirect_to @order_material, notice: 'Order material was successfully updated.' }
        format.js
      else
        format.html { render :edit }
        format.js
      end
    end
  end

  def destroy
    @order_material.destroy
    respond_to do |format|
      format.html { redirect_to _order_materials_url, notice: 'Order material was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_order_material
      @order_material = OrderMaterial.find(params[:id])
    end

    def order_material_params
      params.require(:order_material).permit(:id,:fax_sended_flag)
    end
end
