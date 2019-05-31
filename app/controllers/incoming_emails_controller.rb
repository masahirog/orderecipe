require 'mail'

class IncomingEmailsController < ActionController::Base
  # protect_from_forgery with: :exception
  def create
    mail = Mail.new(params[:message])
    # TODO: use 'mail' object
    # see API for https://github.com/mikel/mail
    render text: "OK"
  end
end
