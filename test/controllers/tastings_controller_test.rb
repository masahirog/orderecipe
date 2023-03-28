require 'test_helper'

class TastingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tasting = tastings(:one)
  end

  test "should get index" do
    get tastings_url
    assert_response :success
  end

  test "should get new" do
    get new_tasting_url
    assert_response :success
  end

  test "should create tasting" do
    assert_difference('Tasting.count') do
      post tastings_url, params: { tasting: {  } }
    end

    assert_redirected_to tasting_url(Tasting.last)
  end

  test "should show tasting" do
    get tasting_url(@tasting)
    assert_response :success
  end

  test "should get edit" do
    get edit_tasting_url(@tasting)
    assert_response :success
  end

  test "should update tasting" do
    patch tasting_url(@tasting), params: { tasting: {  } }
    assert_redirected_to tasting_url(@tasting)
  end

  test "should destroy tasting" do
    assert_difference('Tasting.count', -1) do
      delete tasting_url(@tasting)
    end

    assert_redirected_to tastings_url
  end
end
