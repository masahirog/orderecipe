class VendorsController < ApplicationController
  def index
    @vendors = Vendor.all
    if params[:month_used_price] == 'true'
      if params[:year] && params[:month]
        @year = params[:year].to_i
        @month = params[:month].to_i
        from = Date.new(@year,@month,1)
        to = Date.new(@year,@month,-1)
        @hash = {}
        OrderMaterial.joins(:order).includes(:material).where(un_order_flag:false,orders:{fixed_flag:1}).where(delivery_date:from..to).each do |om|
          if @hash[om.material.vendor_id].present?
            @hash[om.material.vendor_id] += om.order_quantity.to_f * om.material.cost_price
          else
            @hash[om.material.vendor_id] = om.order_quantity.to_f * om.material.cost_price
          end
        end
      end
    end
  end

  def new
    @vendor = Vendor.new
  end
  def create
    @vendor = Vendor.create(vendor_params)
    if @vendor.save
      redirect_to vendors_path
    else
      render 'new'
    end
  end
  def show
    @vendor = Vendor.find(params[:id])
  end

  def edit
    @vendor = Vendor.find(params[:id])
  end
  def update
    @vendor = Vendor.find(params[:id])
    @vendor.update(vendor_params)
    if @vendor.save
      redirect_to vendors_path
    else
      render 'edit'
    end
  end


  private
  def vendor_params
    params.require(:vendor).permit(:company_name, :company_phone, :company_fax, :company_mail,:efax_address,
                                    :zip, :address, :staff_name, :staff_phone, :staff_mail, :memo)
  end
end
