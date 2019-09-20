class CookingRicesController < ApplicationController
  before_action :set_cooking_rice, only: [:show, :edit, :update, :destroy]
  def index
    @cooking_rices = CookingRice.all
  end

  def show
  end

  def new
    @cooking_rice = CookingRice.new
  end

  def edit
  end

  def create
    @cooking_rice = CookingRice.new(cooking_rice_params)

    respond_to do |format|
      if @cooking_rice.save
        format.html { redirect_to @cooking_rice, notice: 'Cooking rice was successfully created.' }
        format.json { render :show, status: :created, location: @cooking_rice }
      else
        format.html { render :new }
        format.json { render json: @cooking_rice.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @cooking_rice.update(cooking_rice_params)
        format.html { redirect_to @cooking_rice, notice: 'Cooking rice was successfully updated.' }
        format.json { render :show, status: :ok, location: @cooking_rice }
      else
        format.html { render :edit }
        format.json { render json: @cooking_rice.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @cooking_rice.destroy
    respond_to do |format|
      format.html { redirect_to _cooking_rices_url, notice: 'Cooking rice was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_cooking_rice
      @cooking_rice = CookingRice.find(params[:id])
    end

    def cooking_rice_params
      params.require(:cooking_rice).permit(:name,:base_rice,:serving_amount,:sho_per_make_num)
    end
end
