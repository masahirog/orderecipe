class BrandsController < ApplicationController
  before_action :set_brand, only: [:show, :edit, :update, :destroy]

  def index
    @brands = Brand.includes(:reviews).all
  end

  def kurumesi_review
    Dotenv.overload
    s3 = Aws::S3::Resource.new(
      region: 'ap-northeast-1',
      credentials: Aws::Credentials.new(
        ENV['ACCESS_KEY_ID'],
        ENV['SECRET_ACCESS_KEY']
      )
    )
    signer = Aws::S3::Presigner.new(client: s3.client)
    @presigned_url = {}
    brand_id = params[:brand_id]
    @reviews = Review.where(brand_id:brand_id)
    @reviews.each do |review|
      file_name = "#{brand_id}_#{review.delivery_date.to_s.gsub(/-/, '')}_#{review.delivery_area}"
      @presigned_url[review.id] = signer.presigned_url(:get_object,bucket: 'review-captures', key: "#{file_name}.jpg", expires_in: 60)
    end
  end

  def show
  end

  def new
    @brand = Brand.new
  end

  def edit
  end

  def create
    @brand = Brand.new(brand_params)

    respond_to do |format|
      if @brand.save
        format.html { redirect_to @brand, notice: 'Brand was successfully created.' }
        format.json { render :show, status: :created, location: @brand }
      else
        format.html { render :new }
        format.json { render json: @brand.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @brand.update(brand_params)
        format.html { redirect_to @brand, notice: 'Brand was successfully updated.' }
        format.json { render :show, status: :ok, location: @brand }
      else
        format.html { render :edit }
        format.json { render json: @brand.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @brand.destroy
    respond_to do |format|
      format.html { redirect_to _brands_url, notice: 'Brand was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_brand
      @brand = Brand.find(params[:id])
    end

    def brand_params
      params.require(:brand).permit(:id,:name)
    end
end
