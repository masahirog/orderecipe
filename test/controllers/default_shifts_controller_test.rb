require 'test_helper'

class DefaultShiftsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @default_shift = default_shifts(:one)
  end

  test "should get index" do
    get default_shifts_url
    assert_response :success
  end

  test "should get new" do
    get new_default_shift_url
    assert_response :success
  end

  test "should create default_shift" do
    assert_difference('DefaultShift.count') do
      post default_shifts_url, params: { default_shift: {  } }
    end

    assert_redirected_to default_shift_url(DefaultShift.last)
  end

  test "should show default_shift" do
    get default_shift_url(@default_shift)
    assert_response :success
  end

  test "should get edit" do
    get edit_default_shift_url(@default_shift)
    assert_response :success
  end

  test "should update default_shift" do
    patch default_shift_url(@default_shift), params: { default_shift: {  } }
    assert_redirected_to default_shift_url(@default_shift)
  end

  test "should destroy default_shift" do
    assert_difference('DefaultShift.count', -1) do
      delete default_shift_url(@default_shift)
    end

    assert_redirected_to default_shifts_url
  end
end
