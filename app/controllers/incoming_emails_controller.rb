require 'mail'
require 'kconv'

class IncomingEmailsController < ApplicationController
  def test
    mail = KurumesiMail.create(message:params[:message])
    # ここに保存＆ブラウザー通知
    render text: "OK"
  end
end
