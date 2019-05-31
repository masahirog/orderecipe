require 'mail'
require 'kconv'

class IncomingEmailsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create
  def create
    mail = Mail.new(params[:message])

    @kurumesi_mail = KurumesiMail.create(message:'aaa')
    # ここに保存＆ブラウザー通知
    render text: "OK"
  end
end
