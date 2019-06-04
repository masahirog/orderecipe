require 'test_helper'

class KurumesiMailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @kurumesi_mail = kurumesi_mails(:one)
  end

  test "should get index" do
    get _kurumesi_mails_url
    assert_response :success
  end

  test "should get new" do
    get new__kurumesi_mail_url
    assert_response :success
  end

  test "should create kurumesi_mail" do
    assert_difference('KurumesiMail.count') do
      post _kurumesi_mails_url, params: { kurumesi_mail: {  } }
    end

    assert_redirected_to kurumesi_mail_url(KurumesiMail.last)
  end

  test "should show kurumesi_mail" do
    get _kurumesi_mail_url(@kurumesi_mail)
    assert_response :success
  end

  test "should get edit" do
    get edit__kurumesi_mail_url(@kurumesi_mail)
    assert_response :success
  end

  test "should update kurumesi_mail" do
    patch _kurumesi_mail_url(@kurumesi_mail), params: { kurumesi_mail: {  } }
    assert_redirected_to kurumesi_mail_url(@kurumesi_mail)
  end

  test "should destroy kurumesi_mail" do
    assert_difference('KurumesiMail.count', -1) do
      delete _kurumesi_mail_url(@kurumesi_mail)
    end

    assert_redirected_to _kurumesi_mails_url
  end
end
