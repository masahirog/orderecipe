class OrdersController < ApplicationController
    def material_info
      @material = Material.find(params[:id])
      respond_to do |format|
        format.html
        format.json
      end
    end

  def confirm
    @order = Order.new(order_create_update)
  end
  def edit
    @order = Order.find(params[:id])
  end

  def index
    @products = Product.all
    @orders = Order.page(params[:page]).order("id DESC")
  end
  def update
    @order = Order.find(params[:id])
    @order.update(order_create_update)
    if @order.save
      redirect_to order_path
    else
      render "edit"
    end
  end

  def new
    @hash = Material.calculate_products_materials(params)
    @order = Order.new
    @order.order_materials.build
    @order.order_products.build
  end

  def create
    @order = Order.create(order_create_update)
     if @order.save
       redirect_to "/orders/#{@order.id}"
     else
       render 'new'
     end
  end

  def show
    @order = Order.find(params[:id])
    @order_materials = @order.order_materials
    @materials = @order.materials
    @vendors = Vendor.vendor_index(params)
  end

  def order_print
    @order = Order.find(params[:id])
    @order_materials = @order.order_materials
    @vendor = Vendor.find(params[:vendor][:id])
    @materials_this_vendor = Material.get_material_this_vendor(params)
    respond_to do |format|
     format.html
     format.pdf do
       pdf = OrderPdf.new(@materials_this_vendor,@order,@order_materials)
       send_data pdf.render,
         filename:    "#{@order.delivery_date}_#{@vendor.company_name}.pdf",
         type:        "application/pdf",
         disposition: "inline"
     end
   end
  end

  def order_print_all
    @order = Order.find(params[:id])
    @order_materials = @order.order_materials
    @vendors = params[:vendor]
    respond_to do |format|
     format.html
     format.pdf do
       pdf = OrderAll.new(@order,@order_materials,@vendors)
       send_data pdf.render,
         filename:    "#{@order.delivery_date}.pdf",
         type:        "application/pdf",
         disposition: "inline"
     end
   end
  end


  private

  def order_create_update
    params.require(:order).permit(:delivery_date,
      order_materials_attributes: [:id, :order_quantity,:calculated_quantity, :order_id, :material_id, :_destroy],
      order_products_attributes: [:id, :serving_for, :order_id, :product_id, :_destroy])
  end

end
