class AdminController < ApplicationController
  before_action :if_not_admin

  #admniコントローラを継承しているページへの入り口ジャッジ
  def if_not_admin
    if current_user.admin?
    elsif current_user.vendor_flag == true
      redirect_to '/vendor/orders'
     else
      redirect_to '/crew/stores'
    end
  end
end
