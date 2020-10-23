class PlaceShowcasesController < ApplicationController
  before_action :set_place_showcase, only: [:show, :edit, :update, :destroy]

  def index
    @place_showcases = PlaceShowcase.all
  end

  def show
  end

  def new
    @place_showcase = PlaceShowcase.new
  end

  def edit
  end

  def create
    @place_showcase = PlaceShowcase.new(place_showcase_params)

    respond_to do |format|
      if @place_showcase.save
        format.html { redirect_to @place_showcase, notice: 'Place showcase was successfully created.' }
        format.json { render :show, status: :created, location: @place_showcase }
      else
        format.html { render :new }
        format.json { render json: @place_showcase.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @place_showcase.update(place_showcase_params)
        format.html { redirect_to @place_showcase, notice: 'Place showcase was successfully updated.' }
        format.json { render :show, status: :ok, location: @place_showcase }
      else
        format.html { render :edit }
        format.json { render json: @place_showcase.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @place_showcase.destroy
    respond_to do |format|
      format.html { redirect_to place_showcases_url, notice: 'Place showcase was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_place_showcase
      @place_showcase = PlaceShowcase.find(params[:id])
    end

    def place_showcase_params
      params.require(:place_showcase).permit(:name)
    end
end
