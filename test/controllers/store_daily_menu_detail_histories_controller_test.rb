require 'test_helper'

class StoreDailyMenuDetailHistoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @store_daily_menu_detail_history = store_daily_menu_detail_histories(:one)
  end

  test "should get index" do
    get store_daily_menu_detail_histories_url
    assert_response :success
  end

  test "should get new" do
    get new_store_daily_menu_detail_history_url
    assert_response :success
  end

  test "should create store_daily_menu_detail_history" do
    assert_difference('StoreDailyMenuDetailHistory.count') do
      post store_daily_menu_detail_histories_url, params: { store_daily_menu_detail_history: {  } }
    end

    assert_redirected_to store_daily_menu_detail_history_url(StoreDailyMenuDetailHistory.last)
  end

  test "should show store_daily_menu_detail_history" do
    get store_daily_menu_detail_history_url(@store_daily_menu_detail_history)
    assert_response :success
  end

  test "should get edit" do
    get edit_store_daily_menu_detail_history_url(@store_daily_menu_detail_history)
    assert_response :success
  end

  test "should update store_daily_menu_detail_history" do
    patch store_daily_menu_detail_history_url(@store_daily_menu_detail_history), params: { store_daily_menu_detail_history: {  } }
    assert_redirected_to store_daily_menu_detail_history_url(@store_daily_menu_detail_history)
  end

  test "should destroy store_daily_menu_detail_history" do
    assert_difference('StoreDailyMenuDetailHistory.count', -1) do
      delete store_daily_menu_detail_history_url(@store_daily_menu_detail_history)
    end

    assert_redirected_to store_daily_menu_detail_histories_url
  end
end
