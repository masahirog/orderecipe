class VendorsController < ApplicationController
  def index
    @vendors = Vendor.all
  end

  def new
    @vendor = Vendor.new
  end
  def create
    Vendor.create(create_params)
    redirect_to vendors_path
  end
  def edit
    @vendor = Vendor.find(params[:id])
  end
  def update
    vendor = Vendor.find(params[:id])
    vendor.update(update_params)
  end


  private
  def create_params
    params.require(:vendor).permit(:company_name, :company_phone, :company_fax, :company_mail,
                                    :zip, :address, :staff_name, :staff_phone, :staff_mail, :memo)
  end
  def update_params
    params.require(:vendor).permit(:company_name, :company_phone, :company_fax, :company_mail,
                    :zip, :address, :staff_name, :staff_phone, :staff_mail, :memo)
  end


end
