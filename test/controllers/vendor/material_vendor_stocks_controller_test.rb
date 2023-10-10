require 'test_helper'

class Vendor::MaterialVendorStocksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @vendor_material_vendor_stock = vendor_material_vendor_stocks(:one)
  end

  test "should get index" do
    get vendor_material_vendor_stocks_url
    assert_response :success
  end

  test "should get new" do
    get new_vendor_material_vendor_stock_url
    assert_response :success
  end

  test "should create vendor_material_vendor_stock" do
    assert_difference('Vendor::MaterialVendorStock.count') do
      post vendor_material_vendor_stocks_url, params: { vendor_material_vendor_stock: {  } }
    end

    assert_redirected_to vendor_material_vendor_stock_url(Vendor::MaterialVendorStock.last)
  end

  test "should show vendor_material_vendor_stock" do
    get vendor_material_vendor_stock_url(@vendor_material_vendor_stock)
    assert_response :success
  end

  test "should get edit" do
    get edit_vendor_material_vendor_stock_url(@vendor_material_vendor_stock)
    assert_response :success
  end

  test "should update vendor_material_vendor_stock" do
    patch vendor_material_vendor_stock_url(@vendor_material_vendor_stock), params: { vendor_material_vendor_stock: {  } }
    assert_redirected_to vendor_material_vendor_stock_url(@vendor_material_vendor_stock)
  end

  test "should destroy vendor_material_vendor_stock" do
    assert_difference('Vendor::MaterialVendorStock.count', -1) do
      delete vendor_material_vendor_stock_url(@vendor_material_vendor_stock)
    end

    assert_redirected_to vendor_material_vendor_stocks_url
  end
end
