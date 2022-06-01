require 'test_helper'

class RefundSupportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @refund_support = refund_supports(:one)
  end

  test "should get index" do
    get refund_supports_url
    assert_response :success
  end

  test "should get new" do
    get new_refund_support_url
    assert_response :success
  end

  test "should create refund_support" do
    assert_difference('RefundSupport.count') do
      post refund_supports_url, params: { refund_support: {  } }
    end

    assert_redirected_to refund_support_url(RefundSupport.last)
  end

  test "should show refund_support" do
    get refund_support_url(@refund_support)
    assert_response :success
  end

  test "should get edit" do
    get edit_refund_support_url(@refund_support)
    assert_response :success
  end

  test "should update refund_support" do
    patch refund_support_url(@refund_support), params: { refund_support: {  } }
    assert_redirected_to refund_support_url(@refund_support)
  end

  test "should destroy refund_support" do
    assert_difference('RefundSupport.count', -1) do
      delete refund_support_url(@refund_support)
    end

    assert_redirected_to refund_supports_url
  end
end
