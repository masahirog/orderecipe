require 'test_helper'

class ItemVendorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @item_vendor = item_vendors(:one)
  end

  test "should get index" do
    get item_vendors_url
    assert_response :success
  end

  test "should get new" do
    get new_item_vendor_url
    assert_response :success
  end

  test "should create item_vendor" do
    assert_difference('ItemVendor.count') do
      post item_vendors_url, params: { item_vendor: {  } }
    end

    assert_redirected_to item_vendor_url(ItemVendor.last)
  end

  test "should show item_vendor" do
    get item_vendor_url(@item_vendor)
    assert_response :success
  end

  test "should get edit" do
    get edit_item_vendor_url(@item_vendor)
    assert_response :success
  end

  test "should update item_vendor" do
    patch item_vendor_url(@item_vendor), params: { item_vendor: {  } }
    assert_redirected_to item_vendor_url(@item_vendor)
  end

  test "should destroy item_vendor" do
    assert_difference('ItemVendor.count', -1) do
      delete item_vendor_url(@item_vendor)
    end

    assert_redirected_to item_vendors_url
  end
end
