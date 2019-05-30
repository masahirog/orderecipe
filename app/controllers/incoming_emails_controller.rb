require 'mail'
require 'kconv'

class IncomingEmailsController < ApplicationController
  def create
    mail = Mail.new(params[:message])

    @kurumesi_mail = KurumesiMail.create(message:mail.body)
    # ここに保存＆ブラウザー通知
    render text: "OK"
  end
end
