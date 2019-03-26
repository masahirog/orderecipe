class StorageLocationsController < ApplicationController
  before_action :set_storage_location, only: [:show, :edit, :update, :destroy]

  def index
    @storage_locations = StorageLocation.all
  end

  def show
  end

  def new
    @storage_location = StorageLocation.new
  end

  def edit
  end

  def create
    @storage_location = StorageLocation.new(storage_location_params)

    respond_to do |format|
      if @storage_location.save
        format.html { redirect_to storage_locations_path, notice: '作成したよん' }
        format.json { render :show, status: :created, location: @storage_location }
      else
        format.html { render :new }
        format.json { render json: @storage_location.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @storage_location.update(storage_location_params)
        format.html { redirect_to  storage_locations_path, notice: '更新したよん' }
        format.json { render :show, status: :ok, location: @storage_location }
      else
        format.html { render :edit }
        format.json { render json: @storage_location.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @storage_location.destroy
    respond_to do |format|
      format.html { redirect_to _storage_locations_url, notice: 'Storage location was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_storage_location
      @storage_location = StorageLocation.find(params[:id])
    end

    def storage_location_params
      params.require(:storage_location).permit(:name)
    end
end
