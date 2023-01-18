class Store::ProductsController < ApplicationController

  def index
    @search = Product.includes(:brand,:order_products,:daily_menu_details,:kurumesi_order_details).search(params).page(params[:page]).per(30)
  end
  def download
    # Dotenv.overload
    # region='ap-northeast-1'
    # bucket='bejihan-orderecipe'
    # key=params[:key]
    # credentials=Aws::Credentials.new(
    #   ENV['ACCESS_KEY_ID'],
    #   ENV['SECRET_ACCESS_KEY']
    # )
    # # send_dataのtypeはtypeで指定
    # client=Aws::S3::Client.new(region:region, credentials:credentials)
    # data=client.get_object(bucket:bucket, key:key).body
    # send_data data.read, filename: params[:file_name], disposition: 'attachment', type: params[:type]
  end

  def show
    @product = Product.includes(:product_menus,{menus: [:menu_materials, :materials]}).find(params[:id])
    @allergies = Product.allergy_seiri(@product)
    @allergies = Product.allergy_seiri(@product)
    @additives = Product.additive_seiri(@product)
    order_products = @product.order_products
    daily_menu_details = @product.daily_menu_details
    kurumesi_order_details = @product.kurumesi_order_details
    unless order_products.present?||daily_menu_details.present?||kurumesi_order_details.present?
      @delete_flag = true
    end
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "#{Time.now.strftime('%Y%m%d')}_product_#{@product.id}.csv", type: :csv
      end
    end
  end
  def download
    Dotenv.overload
    region='ap-northeast-1'
    bucket='bejihan-orderecipe'
    key=params[:key]
    credentials=Aws::Credentials.new(
      ENV['ACCESS_KEY_ID'],
      ENV['SECRET_ACCESS_KEY']
    )
    # send_dataのtypeはtypeで指定
    client=Aws::S3::Client.new(region:region, credentials:credentials)
    data=client.get_object(bucket:bucket, key:key).body
    send_data data.read, filename: params[:file_name], disposition: 'attachment', type: params[:type]
  end
end
