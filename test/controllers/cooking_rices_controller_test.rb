require 'test_helper'

class CookingRicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cooking_rice = cooking_rices(:one)
  end

  test "should get index" do
    get _cooking_rices_url
    assert_response :success
  end

  test "should get new" do
    get new__cooking_rice_url
    assert_response :success
  end

  test "should create cooking_rice" do
    assert_difference('CookingRice.count') do
      post _cooking_rices_url, params: { cooking_rice: {  } }
    end

    assert_redirected_to cooking_rice_url(CookingRice.last)
  end

  test "should show cooking_rice" do
    get _cooking_rice_url(@cooking_rice)
    assert_response :success
  end

  test "should get edit" do
    get edit__cooking_rice_url(@cooking_rice)
    assert_response :success
  end

  test "should update cooking_rice" do
    patch _cooking_rice_url(@cooking_rice), params: { cooking_rice: {  } }
    assert_redirected_to cooking_rice_url(@cooking_rice)
  end

  test "should destroy cooking_rice" do
    assert_difference('CookingRice.count', -1) do
      delete _cooking_rice_url(@cooking_rice)
    end

    assert_redirected_to _cooking_rices_url
  end
end
