require 'test_helper'

class WorkingHourWorkTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @working_hour_work_type = working_hour_work_types(:one)
  end

  test "should get index" do
    get working_hour_work_types_url
    assert_response :success
  end

  test "should get new" do
    get new_working_hour_work_type_url
    assert_response :success
  end

  test "should create working_hour_work_type" do
    assert_difference('WorkingHourWorkType.count') do
      post working_hour_work_types_url, params: { working_hour_work_type: {  } }
    end

    assert_redirected_to working_hour_work_type_url(WorkingHourWorkType.last)
  end

  test "should show working_hour_work_type" do
    get working_hour_work_type_url(@working_hour_work_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_working_hour_work_type_url(@working_hour_work_type)
    assert_response :success
  end

  test "should update working_hour_work_type" do
    patch working_hour_work_type_url(@working_hour_work_type), params: { working_hour_work_type: {  } }
    assert_redirected_to working_hour_work_type_url(@working_hour_work_type)
  end

  test "should destroy working_hour_work_type" do
    assert_difference('WorkingHourWorkType.count', -1) do
      delete working_hour_work_type_url(@working_hour_work_type)
    end

    assert_redirected_to working_hour_work_types_url
  end
end
