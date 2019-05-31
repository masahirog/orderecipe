require 'mail'

class IncomingEmailsController < ApplicationController
  protect_from_forgery except: :create
  def create
    mail = Mail.new(params[:message])
    # TODO: use 'mail' object
    # see API for https://github.com/mikel/mail
    @kurumesi_mail = KurumesiMail.new(message:'aaa')
    @kurumesi_mail.save

    # render text: "OK"
  end
end
