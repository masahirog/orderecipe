require 'test_helper'

class MaterialStoreOrderablesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @material_store_orderable = material_store_orderables(:one)
  end

  test "should get index" do
    get material_store_orderables_url
    assert_response :success
  end

  test "should get new" do
    get new_material_store_orderable_url
    assert_response :success
  end

  test "should create material_store_orderable" do
    assert_difference('MaterialStoreOrderable.count') do
      post material_store_orderables_url, params: { material_store_orderable: {  } }
    end

    assert_redirected_to material_store_orderable_url(MaterialStoreOrderable.last)
  end

  test "should show material_store_orderable" do
    get material_store_orderable_url(@material_store_orderable)
    assert_response :success
  end

  test "should get edit" do
    get edit_material_store_orderable_url(@material_store_orderable)
    assert_response :success
  end

  test "should update material_store_orderable" do
    patch material_store_orderable_url(@material_store_orderable), params: { material_store_orderable: {  } }
    assert_redirected_to material_store_orderable_url(@material_store_orderable)
  end

  test "should destroy material_store_orderable" do
    assert_difference('MaterialStoreOrderable.count', -1) do
      delete material_store_orderable_url(@material_store_orderable)
    end

    assert_redirected_to material_store_orderables_url
  end
end
