require 'test_helper'

class StoreDailyMenusControllerTest < ActionDispatch::IntegrationTest
  setup do
    @store_daily_menu = store_daily_menus(:one)
  end

  test "should get index" do
    get _store_daily_menus_url
    assert_response :success
  end

  test "should get new" do
    get new__store_daily_menu_url
    assert_response :success
  end

  test "should create store_daily_menu" do
    assert_difference('StoreDailyMenu.count') do
      post _store_daily_menus_url, params: { store_daily_menu: {  } }
    end

    assert_redirected_to store_daily_menu_url(StoreDailyMenu.last)
  end

  test "should show store_daily_menu" do
    get _store_daily_menu_url(@store_daily_menu)
    assert_response :success
  end

  test "should get edit" do
    get edit__store_daily_menu_url(@store_daily_menu)
    assert_response :success
  end

  test "should update store_daily_menu" do
    patch _store_daily_menu_url(@store_daily_menu), params: { store_daily_menu: {  } }
    assert_redirected_to store_daily_menu_url(@store_daily_menu)
  end

  test "should destroy store_daily_menu" do
    assert_difference('StoreDailyMenu.count', -1) do
      delete _store_daily_menu_url(@store_daily_menu)
    end

    assert_redirected_to _store_daily_menus_url
  end
end
