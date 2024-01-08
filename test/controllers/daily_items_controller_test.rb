require 'test_helper'

class DailyItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @daily_item = daily_items(:one)
  end

  test "should get index" do
    get daily_items_url
    assert_response :success
  end

  test "should get new" do
    get new_daily_item_url
    assert_response :success
  end

  test "should create daily_item" do
    assert_difference('DailyItem.count') do
      post daily_items_url, params: { daily_item: {  } }
    end

    assert_redirected_to daily_item_url(DailyItem.last)
  end

  test "should show daily_item" do
    get daily_item_url(@daily_item)
    assert_response :success
  end

  test "should get edit" do
    get edit_daily_item_url(@daily_item)
    assert_response :success
  end

  test "should update daily_item" do
    patch daily_item_url(@daily_item), params: { daily_item: {  } }
    assert_redirected_to daily_item_url(@daily_item)
  end

  test "should destroy daily_item" do
    assert_difference('DailyItem.count', -1) do
      delete daily_item_url(@daily_item)
    end

    assert_redirected_to daily_items_url
  end
end
