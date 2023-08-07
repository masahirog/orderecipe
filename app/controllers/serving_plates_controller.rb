class ServingPlatesController < ApplicationController
  before_action :set_serving_plate, only: [:show, :edit, :update, :destroy]

  def index
    @serving_plates = ServingPlate.all
  end

  def show
  end

  def new
    @serving_plate = ServingPlate.new
  end

  def edit
  end

  def create
    @serving_plate = ServingPlate.new(serving_plate_params)

    respond_to do |format|
      if @serving_plate.save
        format.html { redirect_to @serving_plate, notice: 'Serving plate was successfully created.' }
        format.json { render :show, status: :created, location: @serving_plate }
      else
        format.html { render :new }
        format.json { render json: @serving_plate.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @serving_plate.update(serving_plate_params)
        format.html { redirect_to @serving_plate, notice: 'Serving plate was successfully updated.' }
        format.json { render :show, status: :ok, location: @serving_plate }
      else
        format.html { render :edit }
        format.json { render json: @serving_plate.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @serving_plate.destroy
    respond_to do |format|
      format.html { redirect_to serving_plates_url, notice: 'Serving plate was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_serving_plate
      @serving_plate = ServingPlate.find(params[:id])
    end

    def serving_plate_params
      params.require(:serving_plate).permit(:name,:image,:color,:shape,:genre, :image_cache, :remove_image)
    end
end
