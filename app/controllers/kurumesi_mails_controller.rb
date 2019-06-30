class KurumesiMailsController < ApplicationController
  before_action :set_kurumesi_mail, only: [:show, :edit, :update, :destroy]

  def index
    @kurumesi_mails = KurumesiMail.includes(:masu_order).search(params).order('recieved_datetime DESC').page(params[:page]).per(20)

  end

  def show
  end

  def new
    @kurumesi_mail = KurumesiMail.new
  end

  def edit
  end

  def create
    @kurumesi_mail = KurumesiMail.new(kurumesi_mail_params)

    respond_to do |format|
      if @kurumesi_mail.save
        format.html { redirect_to @kurumesi_mail, notice: 'Kurumesi mail was successfully created.' }
        format.json { render :show, status: :created, location: @kurumesi_mail }
      else
        format.html { render :new }
        format.json { render json: @kurumesi_mail.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @kurumesi_mail.update(kurumesi_mail_params)
        format.html { redirect_to @kurumesi_mail, notice: 'Kurumesi mail was successfully updated.' }
        format.json { render :show, status: :ok, location: @kurumesi_mail }
      else
        format.html { render :edit }
        format.json { render json: @kurumesi_mail.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @kurumesi_mail.destroy
    respond_to do |format|
      format.html { redirect_to _kurumesi_mails_url, notice: 'Kurumesi mail was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_kurumesi_mail
      @kurumesi_mail = KurumesiMail.find(params[:id])
    end

    def kurumesi_mail_params
      params.require(:kurumesi_mail).permit(:id,:masu_order_id,:subject,:body,:status,:recieved_datetime,:masu_order_reflect_flag)
    end
end
