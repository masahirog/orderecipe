class ApplicationController < ActionController::Base
  # http_basic_authenticate_with :name => ENV['BASIC_AUTH_USERNAME'], :password => ENV['BASIC_AUTH_PASSWORD'] if Rails.env == "production"
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_action :authenticate_user!
  protect_from_forgery with: :exception

  def render_500(e)
  ExceptionNotifier.notify_exception(e, :env => request.env, :data => {:message => "your error message"})
  render template: 'errors/error_500', status: 500
  end


  protected
    def revert_link
      view_context.link_to('取消', revert_version_path(@material.versions.last), :method => :post)
    end
    def versions_link
      view_context.link_to('編集履歴', version_path(@material), :method => :get)
    end
    def revert_link_menu
      view_context.link_to('取消', revert_version_path(@menu.versions.last), :method => :post)
    end
end
