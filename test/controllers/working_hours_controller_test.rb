require 'test_helper'

class WorkingHoursControllerTest < ActionDispatch::IntegrationTest
  setup do
    @working_hour = working_hours(:one)
  end

  test "should get index" do
    get working_hours_url
    assert_response :success
  end

  test "should get new" do
    get new_working_hour_url
    assert_response :success
  end

  test "should create working_hour" do
    assert_difference('WorkingHour.count') do
      post working_hours_url, params: { working_hour: {  } }
    end

    assert_redirected_to working_hour_url(WorkingHour.last)
  end

  test "should show working_hour" do
    get working_hour_url(@working_hour)
    assert_response :success
  end

  test "should get edit" do
    get edit_working_hour_url(@working_hour)
    assert_response :success
  end

  test "should update working_hour" do
    patch working_hour_url(@working_hour), params: { working_hour: {  } }
    assert_redirected_to working_hour_url(@working_hour)
  end

  test "should destroy working_hour" do
    assert_difference('WorkingHour.count', -1) do
      delete working_hour_url(@working_hour)
    end

    assert_redirected_to working_hours_url
  end
end
