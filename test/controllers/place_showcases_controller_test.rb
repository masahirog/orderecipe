require 'test_helper'

class PlaceShowcasesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @place_showcase = place_showcases(:one)
  end

  test "should get index" do
    get place_showcases_url
    assert_response :success
  end

  test "should get new" do
    get new_place_showcase_url
    assert_response :success
  end

  test "should create place_showcase" do
    assert_difference('PlaceShowcase.count') do
      post place_showcases_url, params: { place_showcase: {  } }
    end

    assert_redirected_to place_showcase_url(PlaceShowcase.last)
  end

  test "should show place_showcase" do
    get place_showcase_url(@place_showcase)
    assert_response :success
  end

  test "should get edit" do
    get edit_place_showcase_url(@place_showcase)
    assert_response :success
  end

  test "should update place_showcase" do
    patch place_showcase_url(@place_showcase), params: { place_showcase: {  } }
    assert_redirected_to place_showcase_url(@place_showcase)
  end

  test "should destroy place_showcase" do
    assert_difference('PlaceShowcase.count', -1) do
      delete place_showcase_url(@place_showcase)
    end

    assert_redirected_to place_showcases_url
  end
end
