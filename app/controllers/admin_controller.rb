class AdminController < ApplicationController
  before_action :if_not_admin
  # layout 'admin'
  def if_not_admin
    if current_user.admin?
    else
      if current_user.id == 49
        redirect_to '/shift'
      else
        redirect_to '/store/store_daily_menus'
      end
    end
  end
end
