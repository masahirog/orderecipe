require 'test_helper'

class ItemOrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @item_order = item_orders(:one)
  end

  test "should get index" do
    get item_orders_url
    assert_response :success
  end

  test "should get new" do
    get new_item_order_url
    assert_response :success
  end

  test "should create item_order" do
    assert_difference('ItemOrder.count') do
      post item_orders_url, params: { item_order: {  } }
    end

    assert_redirected_to item_order_url(ItemOrder.last)
  end

  test "should show item_order" do
    get item_order_url(@item_order)
    assert_response :success
  end

  test "should get edit" do
    get edit_item_order_url(@item_order)
    assert_response :success
  end

  test "should update item_order" do
    patch item_order_url(@item_order), params: { item_order: {  } }
    assert_redirected_to item_order_url(@item_order)
  end

  test "should destroy item_order" do
    assert_difference('ItemOrder.count', -1) do
      delete item_order_url(@item_order)
    end

    assert_redirected_to item_orders_url
  end
end
