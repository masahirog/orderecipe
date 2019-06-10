require 'test_helper'

class BrandsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @brand = brands(:one)
  end

  test "should get index" do
    get _brands_url
    assert_response :success
  end

  test "should get new" do
    get new__brand_url
    assert_response :success
  end

  test "should create brand" do
    assert_difference('Brand.count') do
      post _brands_url, params: { brand: {  } }
    end

    assert_redirected_to brand_url(Brand.last)
  end

  test "should show brand" do
    get _brand_url(@brand)
    assert_response :success
  end

  test "should get edit" do
    get edit__brand_url(@brand)
    assert_response :success
  end

  test "should update brand" do
    patch _brand_url(@brand), params: { brand: {  } }
    assert_redirected_to brand_url(@brand)
  end

  test "should destroy brand" do
    assert_difference('Brand.count', -1) do
      delete _brand_url(@brand)
    end

    assert_redirected_to _brands_url
  end
end
