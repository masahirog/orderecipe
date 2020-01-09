require 'test_helper'

class KurumesiAdminDatasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @kurumesi_admin_data = kurumesi_admin_data(:one)
  end

  test "should get index" do
    get _kurumesi_admin_data_url
    assert_response :success
  end

  test "should get new" do
    get new__kurumesi_admin_data_url
    assert_response :success
  end

  test "should create kurumesi_admin_data" do
    assert_difference('KurumesiAdminData.count') do
      post _kurumesi_admin_data_url, params: { kurumesi_admin_data: {  } }
    end

    assert_redirected_to kurumesi_admin_data_url(KurumesiAdminData.last)
  end

  test "should show kurumesi_admin_data" do
    get _kurumesi_admin_data_url(@kurumesi_admin_data)
    assert_response :success
  end

  test "should get edit" do
    get edit__kurumesi_admin_data_url(@kurumesi_admin_data)
    assert_response :success
  end

  test "should update kurumesi_admin_data" do
    patch _kurumesi_admin_data_url(@kurumesi_admin_data), params: { kurumesi_admin_data: {  } }
    assert_redirected_to kurumesi_admin_data_url(@kurumesi_admin_data)
  end

  test "should destroy kurumesi_admin_data" do
    assert_difference('KurumesiAdminData.count', -1) do
      delete _kurumesi_admin_data_url(@kurumesi_admin_data)
    end

    assert_redirected_to _kurumesi_admin_data_url
  end
end
