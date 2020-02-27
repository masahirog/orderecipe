require 'test_helper'

class OrderMaterialsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @order_material = order_materials(:one)
  end

  test "should get index" do
    get _order_materials_url
    assert_response :success
  end

  test "should get new" do
    get new__order_material_url
    assert_response :success
  end

  test "should create order_material" do
    assert_difference('OrderMaterial.count') do
      post _order_materials_url, params: { order_material: {  } }
    end

    assert_redirected_to order_material_url(OrderMaterial.last)
  end

  test "should show order_material" do
    get _order_material_url(@order_material)
    assert_response :success
  end

  test "should get edit" do
    get edit__order_material_url(@order_material)
    assert_response :success
  end

  test "should update order_material" do
    patch _order_material_url(@order_material), params: { order_material: {  } }
    assert_redirected_to order_material_url(@order_material)
  end

  test "should destroy order_material" do
    assert_difference('OrderMaterial.count', -1) do
      delete _order_material_url(@order_material)
    end

    assert_redirected_to _order_materials_url
  end
end
