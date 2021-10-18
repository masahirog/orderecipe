require 'test_helper'

class AnalysisProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @analysis_product = analysis_products(:one)
  end

  test "should get index" do
    get analysis_products_url
    assert_response :success
  end

  test "should get new" do
    get new_analysis_product_url
    assert_response :success
  end

  test "should create analysis_product" do
    assert_difference('AnalysisProduct.count') do
      post analysis_products_url, params: { analysis_product: {  } }
    end

    assert_redirected_to analysis_product_url(AnalysisProduct.last)
  end

  test "should show analysis_product" do
    get analysis_product_url(@analysis_product)
    assert_response :success
  end

  test "should get edit" do
    get edit_analysis_product_url(@analysis_product)
    assert_response :success
  end

  test "should update analysis_product" do
    patch analysis_product_url(@analysis_product), params: { analysis_product: {  } }
    assert_redirected_to analysis_product_url(@analysis_product)
  end

  test "should destroy analysis_product" do
    assert_difference('AnalysisProduct.count', -1) do
      delete analysis_product_url(@analysis_product)
    end

    assert_redirected_to analysis_products_url
  end
end
