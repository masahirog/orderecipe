require 'test_helper'

class StoreDailyMenuDetailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @store_daily_menu_detail = store_daily_menu_details(:one)
  end

  test "should get index" do
    get store_daily_menu_details_url
    assert_response :success
  end

  test "should get new" do
    get new_store_daily_menu_detail_url
    assert_response :success
  end

  test "should create store_daily_menu_detail" do
    assert_difference('StoreDailyMenuDetail.count') do
      post store_daily_menu_details_url, params: { store_daily_menu_detail: {  } }
    end

    assert_redirected_to store_daily_menu_detail_url(StoreDailyMenuDetail.last)
  end

  test "should show store_daily_menu_detail" do
    get store_daily_menu_detail_url(@store_daily_menu_detail)
    assert_response :success
  end

  test "should get edit" do
    get edit_store_daily_menu_detail_url(@store_daily_menu_detail)
    assert_response :success
  end

  test "should update store_daily_menu_detail" do
    patch store_daily_menu_detail_url(@store_daily_menu_detail), params: { store_daily_menu_detail: {  } }
    assert_redirected_to store_daily_menu_detail_url(@store_daily_menu_detail)
  end

  test "should destroy store_daily_menu_detail" do
    assert_difference('StoreDailyMenuDetail.count', -1) do
      delete store_daily_menu_detail_url(@store_daily_menu_detail)
    end

    assert_redirected_to store_daily_menu_details_url
  end
end
