require 'test_helper'

class DailyMenusControllerTest < ActionDispatch::IntegrationTest
  setup do
    @daily_menu = daily_menus(:one)
  end

  test "should get index" do
    get _daily_menus_url
    assert_response :success
  end

  test "should get new" do
    get new__daily_menu_url
    assert_response :success
  end

  test "should create daily_menu" do
    assert_difference('DailyMenu.count') do
      post _daily_menus_url, params: { daily_menu: {  } }
    end

    assert_redirected_to daily_menu_url(DailyMenu.last)
  end

  test "should show daily_menu" do
    get _daily_menu_url(@daily_menu)
    assert_response :success
  end

  test "should get edit" do
    get edit__daily_menu_url(@daily_menu)
    assert_response :success
  end

  test "should update daily_menu" do
    patch _daily_menu_url(@daily_menu), params: { daily_menu: {  } }
    assert_redirected_to daily_menu_url(@daily_menu)
  end

  test "should destroy daily_menu" do
    assert_difference('DailyMenu.count', -1) do
      delete _daily_menu_url(@daily_menu)
    end

    assert_redirected_to _daily_menus_url
  end
end
