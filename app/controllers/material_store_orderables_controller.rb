class MaterialStoreOrderablesController < ApplicationController
  before_action :set_material_store_orderable, only: %i[ show edit update destroy ]

  def index
    @material_store_orderables = MaterialStoreOrderable.all
  end

  def show
  end

  def new
    @material_store_orderable = MaterialStoreOrderable.new
  end

  def edit
  end

  def create
    @material_store_orderable = MaterialStoreOrderable.new(material_store_orderable_params)
    respond_to do |format|
      if @material_store_orderable.save
        format.js
        format.html { redirect_to @material_store_orderable, notice: "Material store orderable was successfully created." }
        format.json { render :show, status: :created, location: @material_store_orderable }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @material_store_orderable.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @material_store_orderable.update(material_store_orderable_params)
        format.js
        format.html { redirect_to @material_store_orderable, notice: "Material store orderable was successfully updated." }
        format.json { render :show, status: :ok, location: @material_store_orderable }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @material_store_orderable.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    store_id = @material_store_orderable.store_id
    material = @material_store_orderable.material
    @material_store_orderable.destroy
    respond_to do |format|
      format.html { redirect_to materials_stores_path(store_id:store_id), notice: "#{material.name}を発注リストから削除しました。" }
      format.json { head :no_content }
    end
  end

  private
    def set_material_store_orderable
      @material_store_orderable = MaterialStoreOrderable.find(params[:id])
    end

    def material_store_orderable_params
      params.require(:material_store_orderable).permit(:material_id,:store_id,:orderable_flag,:order_criterion,:mon,:tue,:wed,:thu,:fri,:sat,:sun)

    end
end
