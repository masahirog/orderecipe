class AdminController < ApplicationController
  before_action :if_not_admin
  # layout 'admin'
  def if_not_admin
    redirect_to '/store/store_daily_menus' unless current_user.admin?
  end
end
