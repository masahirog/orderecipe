require 'test_helper'

class TemporaryProductMenusControllerTest < ActionDispatch::IntegrationTest
  setup do
    @temporary_product_menu = temporary_product_menus(:one)
  end

  test "should get index" do
    get temporary_product_menus_url
    assert_response :success
  end

  test "should get new" do
    get new_temporary_product_menu_url
    assert_response :success
  end

  test "should create temporary_product_menu" do
    assert_difference('TemporaryProductMenu.count') do
      post temporary_product_menus_url, params: { temporary_product_menu: {  } }
    end

    assert_redirected_to temporary_product_menu_url(TemporaryProductMenu.last)
  end

  test "should show temporary_product_menu" do
    get temporary_product_menu_url(@temporary_product_menu)
    assert_response :success
  end

  test "should get edit" do
    get edit_temporary_product_menu_url(@temporary_product_menu)
    assert_response :success
  end

  test "should update temporary_product_menu" do
    patch temporary_product_menu_url(@temporary_product_menu), params: { temporary_product_menu: {  } }
    assert_redirected_to temporary_product_menu_url(@temporary_product_menu)
  end

  test "should destroy temporary_product_menu" do
    assert_difference('TemporaryProductMenu.count', -1) do
      delete temporary_product_menu_url(@temporary_product_menu)
    end

    assert_redirected_to temporary_product_menus_url
  end
end
