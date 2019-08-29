class VendorsController < ApplicationController
  def index
    @vendors = Vendor.all
    @vendor = Vendor.new

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
