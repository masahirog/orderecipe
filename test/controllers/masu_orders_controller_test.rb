require 'test_helper'

class MasuOrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @masu_order = masu_orders(:one)
  end

  test "should get index" do
    get masu_orders_url
    assert_response :success
  end

  test "should get new" do
    get new_masu_order_url
    assert_response :success
  end

  test "should create masu_order" do
    assert_difference('MasuOrder.count') do
      post masu_orders_url, params: { masu_order: {  } }
    end

    assert_redirected_to masu_order_url(MasuOrder.last)
  end

  test "should show masu_order" do
    get masu_order_url(@masu_order)
    assert_response :success
  end

  test "should get edit" do
    get edit_masu_order_url(@masu_order)
    assert_response :success
  end

  test "should update masu_order" do
    patch masu_order_url(@masu_order), params: { masu_order: {  } }
    assert_redirected_to masu_order_url(@masu_order)
  end

  test "should destroy masu_order" do
    assert_difference('MasuOrder.count', -1) do
      delete masu_order_url(@masu_order)
    end

    assert_redirected_to masu_orders_url
  end
end
