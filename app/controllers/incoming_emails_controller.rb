require 'mail'
require 'kconv'

class IncomingEmailsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: :test
  def test
    mail = KurumesiMail.create(message:params[:message])
    # ここに保存＆ブラウザー通知
    render text: "OK"
  end
end
