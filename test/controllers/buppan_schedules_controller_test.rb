require 'test_helper'

class BuppanSchedulesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @buppan_schedule = buppan_schedules(:one)
  end

  test "should get index" do
    get buppan_schedules_url
    assert_response :success
  end

  test "should get new" do
    get new_buppan_schedule_url
    assert_response :success
  end

  test "should create buppan_schedule" do
    assert_difference('BuppanSchedule.count') do
      post buppan_schedules_url, params: { buppan_schedule: {  } }
    end

    assert_redirected_to buppan_schedule_url(BuppanSchedule.last)
  end

  test "should show buppan_schedule" do
    get buppan_schedule_url(@buppan_schedule)
    assert_response :success
  end

  test "should get edit" do
    get edit_buppan_schedule_url(@buppan_schedule)
    assert_response :success
  end

  test "should update buppan_schedule" do
    patch buppan_schedule_url(@buppan_schedule), params: { buppan_schedule: {  } }
    assert_redirected_to buppan_schedule_url(@buppan_schedule)
  end

  test "should destroy buppan_schedule" do
    assert_difference('BuppanSchedule.count', -1) do
      delete buppan_schedule_url(@buppan_schedule)
    end

    assert_redirected_to buppan_schedules_url
  end
end
