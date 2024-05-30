require 'test_helper'

class PreOrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pre_order = pre_orders(:one)
  end

  test "should get index" do
    get pre_orders_url
    assert_response :success
  end

  test "should get new" do
    get new_pre_order_url
    assert_response :success
  end

  test "should create pre_order" do
    assert_difference('PreOrder.count') do
      post pre_orders_url, params: { pre_order: {  } }
    end

    assert_redirected_to pre_order_url(PreOrder.last)
  end

  test "should show pre_order" do
    get pre_order_url(@pre_order)
    assert_response :success
  end

  test "should get edit" do
    get edit_pre_order_url(@pre_order)
    assert_response :success
  end

  test "should update pre_order" do
    patch pre_order_url(@pre_order), params: { pre_order: {  } }
    assert_redirected_to pre_order_url(@pre_order)
  end

  test "should destroy pre_order" do
    assert_difference('PreOrder.count', -1) do
      delete pre_order_url(@pre_order)
    end

    assert_redirected_to pre_orders_url
  end
end
