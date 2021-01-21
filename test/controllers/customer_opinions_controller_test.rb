require 'test_helper'

class CustomerOpinionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer_opinion = customer_opinions(:one)
  end

  test "should get index" do
    get _customer_opinions_url
    assert_response :success
  end

  test "should get new" do
    get new__customer_opinion_url
    assert_response :success
  end

  test "should create customer_opinion" do
    assert_difference('CustomerOpinion.count') do
      post _customer_opinions_url, params: { customer_opinion: {  } }
    end

    assert_redirected_to customer_opinion_url(CustomerOpinion.last)
  end

  test "should show customer_opinion" do
    get _customer_opinion_url(@customer_opinion)
    assert_response :success
  end

  test "should get edit" do
    get edit__customer_opinion_url(@customer_opinion)
    assert_response :success
  end

  test "should update customer_opinion" do
    patch _customer_opinion_url(@customer_opinion), params: { customer_opinion: {  } }
    assert_redirected_to customer_opinion_url(@customer_opinion)
  end

  test "should destroy customer_opinion" do
    assert_difference('CustomerOpinion.count', -1) do
      delete _customer_opinion_url(@customer_opinion)
    end

    assert_redirected_to _customer_opinions_url
  end
end
