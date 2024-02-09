require 'test_helper'

class ItemExpirationDatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @item_expiration_date = item_expiration_dates(:one)
  end

  test "should get index" do
    get item_expiration_dates_url
    assert_response :success
  end

  test "should get new" do
    get new_item_expiration_date_url
    assert_response :success
  end

  test "should create item_expiration_date" do
    assert_difference('ItemExpirationDate.count') do
      post item_expiration_dates_url, params: { item_expiration_date: {  } }
    end

    assert_redirected_to item_expiration_date_url(ItemExpirationDate.last)
  end

  test "should show item_expiration_date" do
    get item_expiration_date_url(@item_expiration_date)
    assert_response :success
  end

  test "should get edit" do
    get edit_item_expiration_date_url(@item_expiration_date)
    assert_response :success
  end

  test "should update item_expiration_date" do
    patch item_expiration_date_url(@item_expiration_date), params: { item_expiration_date: {  } }
    assert_redirected_to item_expiration_date_url(@item_expiration_date)
  end

  test "should destroy item_expiration_date" do
    assert_difference('ItemExpirationDate.count', -1) do
      delete item_expiration_date_url(@item_expiration_date)
    end

    assert_redirected_to item_expiration_dates_url
  end
end
