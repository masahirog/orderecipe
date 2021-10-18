require 'test_helper'

class ProductSalesPotentialsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product_sales_potential = product_sales_potentials(:one)
  end

  test "should get index" do
    get product_sales_potentials_url
    assert_response :success
  end

  test "should get new" do
    get new_product_sales_potential_url
    assert_response :success
  end

  test "should create product_sales_potential" do
    assert_difference('ProductSalesPotential.count') do
      post product_sales_potentials_url, params: { product_sales_potential: {  } }
    end

    assert_redirected_to product_sales_potential_url(ProductSalesPotential.last)
  end

  test "should show product_sales_potential" do
    get product_sales_potential_url(@product_sales_potential)
    assert_response :success
  end

  test "should get edit" do
    get edit_product_sales_potential_url(@product_sales_potential)
    assert_response :success
  end

  test "should update product_sales_potential" do
    patch product_sales_potential_url(@product_sales_potential), params: { product_sales_potential: {  } }
    assert_redirected_to product_sales_potential_url(@product_sales_potential)
  end

  test "should destroy product_sales_potential" do
    assert_difference('ProductSalesPotential.count', -1) do
      delete product_sales_potential_url(@product_sales_potential)
    end

    assert_redirected_to product_sales_potentials_url
  end
end
