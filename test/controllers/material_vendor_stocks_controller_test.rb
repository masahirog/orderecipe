require 'test_helper'

class MaterialVendorStocksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @material_vendor_stock = material_vendor_stocks(:one)
  end

  test "should get index" do
    get material_vendor_stocks_url
    assert_response :success
  end

  test "should get new" do
    get new_material_vendor_stock_url
    assert_response :success
  end

  test "should create material_vendor_stock" do
    assert_difference('MaterialVendorStock.count') do
      post material_vendor_stocks_url, params: { material_vendor_stock: {  } }
    end

    assert_redirected_to material_vendor_stock_url(MaterialVendorStock.last)
  end

  test "should show material_vendor_stock" do
    get material_vendor_stock_url(@material_vendor_stock)
    assert_response :success
  end

  test "should get edit" do
    get edit_material_vendor_stock_url(@material_vendor_stock)
    assert_response :success
  end

  test "should update material_vendor_stock" do
    patch material_vendor_stock_url(@material_vendor_stock), params: { material_vendor_stock: {  } }
    assert_redirected_to material_vendor_stock_url(@material_vendor_stock)
  end

  test "should destroy material_vendor_stock" do
    assert_difference('MaterialVendorStock.count', -1) do
      delete material_vendor_stock_url(@material_vendor_stock)
    end

    assert_redirected_to material_vendor_stocks_url
  end
end
