require 'test_helper'

class ServingPlatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @serving_plate = serving_plates(:one)
  end

  test "should get index" do
    get serving_plates_url
    assert_response :success
  end

  test "should get new" do
    get new_serving_plate_url
    assert_response :success
  end

  test "should create serving_plate" do
    assert_difference('ServingPlate.count') do
      post serving_plates_url, params: { serving_plate: {  } }
    end

    assert_redirected_to serving_plate_url(ServingPlate.last)
  end

  test "should show serving_plate" do
    get serving_plate_url(@serving_plate)
    assert_response :success
  end

  test "should get edit" do
    get edit_serving_plate_url(@serving_plate)
    assert_response :success
  end

  test "should update serving_plate" do
    patch serving_plate_url(@serving_plate), params: { serving_plate: {  } }
    assert_redirected_to serving_plate_url(@serving_plate)
  end

  test "should destroy serving_plate" do
    assert_difference('ServingPlate.count', -1) do
      delete serving_plate_url(@serving_plate)
    end

    assert_redirected_to serving_plates_url
  end
end
