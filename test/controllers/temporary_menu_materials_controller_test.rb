require 'test_helper'

class TemporaryMenuMaterialsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @temporary_menu_material = temporary_menu_materials(:one)
  end

  test "should get index" do
    get temporary_menu_materials_url
    assert_response :success
  end

  test "should get new" do
    get new_temporary_menu_material_url
    assert_response :success
  end

  test "should create temporary_menu_material" do
    assert_difference('TemporaryMenuMaterial.count') do
      post temporary_menu_materials_url, params: { temporary_menu_material: {  } }
    end

    assert_redirected_to temporary_menu_material_url(TemporaryMenuMaterial.last)
  end

  test "should show temporary_menu_material" do
    get temporary_menu_material_url(@temporary_menu_material)
    assert_response :success
  end

  test "should get edit" do
    get edit_temporary_menu_material_url(@temporary_menu_material)
    assert_response :success
  end

  test "should update temporary_menu_material" do
    patch temporary_menu_material_url(@temporary_menu_material), params: { temporary_menu_material: {  } }
    assert_redirected_to temporary_menu_material_url(@temporary_menu_material)
  end

  test "should destroy temporary_menu_material" do
    assert_difference('TemporaryMenuMaterial.count', -1) do
      delete temporary_menu_material_url(@temporary_menu_material)
    end

    assert_redirected_to temporary_menu_materials_url
  end
end
