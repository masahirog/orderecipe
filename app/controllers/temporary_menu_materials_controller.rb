class TemporaryMenuMaterialsController < ApplicationController
  before_action :set_temporary_menu_material, only: %i[ show edit update destroy ]

  def ikkatsu_update
    menu_material_id = params['menu_material_id']
    menu_material = MenuMaterial.find(menu_material_id)
    new_arr = []
    update_arr = []
    dates = params["temporary_menu_material"].keys
    tmms_hash = TemporaryMenuMaterial.where(menu_material_id:menu_material_id,date:dates).map{|tmm|[tmm.date,tmm]}.to_h
    params["temporary_menu_material"].each do |temporary_menu_material_params|
      
      date = temporary_menu_material_params[0].to_date
      # 既存のtmmがあるかどうか？
      temporary_menu_material = tmms_hash[date]

      material_id = temporary_menu_material_params[1]["material_id"]
      if material_id.present?
        if temporary_menu_material.present?
          temporary_menu_material.material_id = material_id
          update_arr << temporary_menu_material
        else
          new_arr << TemporaryMenuMaterial.new(date:date,material_id:material_id,menu_material_id:menu_material_id,origin_material_id:menu_material.material_id)
        end
      else
        temporary_menu_material.destroy if temporary_menu_material.present?
      end
    end
    TemporaryMenuMaterial.import update_arr, on_duplicate_key_update:[:material_id]
    TemporaryMenuMaterial.import new_arr
    redirect_to new_temporary_menu_material_path(menu_material_id:menu_material_id),success:'情報を更新しました。'
  end
  def index
    if params[:material_id].present?
      if params[:past_include] == "true"
        @temporary_menu_materials = TemporaryMenuMaterial.includes(:material,menu_material:[:material,:menu]).where(origin_material_id:params[:material_id])
      else
        @temporary_menu_materials = TemporaryMenuMaterial.includes(:material,menu_material:[:material,:menu]).where("date >= ?",@today).where(origin_material_id:params[:material_id])
      end
    else
      if params[:past_include] == "true"
        @temporary_menu_materials = TemporaryMenuMaterial.includes(:material,menu_material:[:material,:menu]).all
      else
        @temporary_menu_materials = TemporaryMenuMaterial.includes(:material,menu_material:[:material,:menu]).where("date >= ?",@today)
      end      
    end
    @uniq_tmms = @temporary_menu_materials.group(:menu_material_id).count
    @uniq_mms_hash = MenuMaterial.includes(:menu,material:[:vendor]).where(id:@uniq_tmms.keys).map{|mm|[mm.id,mm]}.to_h
  end

  def material_date
    material_id = params[:material_id]
    @date = params[:date]
    @material = Material.find(material_id)
    @temporary_menu_materials = TemporaryMenuMaterial.where(origin_material_id:material_id,date:@date)
    
  end

  def show
  end

  def new
    if params[:date].present?
      @date = Date.parse(params[:date])
    else
      @date = @today
    end
    @dates = (@date.beginning_of_month..@date.end_of_month).to_a
    @next = @date.next_month
    @last = @date.last_month
    @menu_material = MenuMaterial.find(params[:menu_material_id])
    @menu_materials =MenuMaterial.where(menu_id:11)
    material_ids = TemporaryMenuMaterial.where(date:@dates,menu_material_id:@menu_material.id).map{|tmm|tmm.material_id}
    @materials = Material.where(id:material_ids)

  end

  def edit
  end

  def create
    @temporary_menu_material = TemporaryMenuMaterial.new(temporary_menu_material_params)

    respond_to do |format|
      if @temporary_menu_material.save
        format.html { redirect_to temporary_menu_material_url(@temporary_menu_material), notice: "Temporary menu material was successfully created." }
        format.json { render :show, status: :created, location: @temporary_menu_material }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @temporary_menu_material.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @temporary_menu_material.update(temporary_menu_material_params)
        format.html { redirect_to temporary_menu_material_url(@temporary_menu_material), notice: "Temporary menu material was successfully updated." }
        format.json { render :show, status: :ok, location: @temporary_menu_material }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @temporary_menu_material.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @temporary_menu_material.destroy

    respond_to do |format|
      format.html { redirect_to temporary_menu_materials_url, notice: "Temporary menu material was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_temporary_menu_material
      @temporary_menu_material = TemporaryMenuMaterial.find(params[:id])
    end

    def temporary_menu_material_params
      params.require(:temporary_menu_material).permit(:menu_material_id,:material_id,:date,:origin_material_id)
    end
end
