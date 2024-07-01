require 'test_helper'

class WeeklyReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @weekly_report = weekly_reports(:one)
  end

  test "should get index" do
    get weekly_reports_url
    assert_response :success
  end

  test "should get new" do
    get new_weekly_report_url
    assert_response :success
  end

  test "should create weekly_report" do
    assert_difference('WeeklyReport.count') do
      post weekly_reports_url, params: { weekly_report: {  } }
    end

    assert_redirected_to weekly_report_url(WeeklyReport.last)
  end

  test "should show weekly_report" do
    get weekly_report_url(@weekly_report)
    assert_response :success
  end

  test "should get edit" do
    get edit_weekly_report_url(@weekly_report)
    assert_response :success
  end

  test "should update weekly_report" do
    patch weekly_report_url(@weekly_report), params: { weekly_report: {  } }
    assert_redirected_to weekly_report_url(@weekly_report)
  end

  test "should destroy weekly_report" do
    assert_difference('WeeklyReport.count', -1) do
      delete weekly_report_url(@weekly_report)
    end

    assert_redirected_to weekly_reports_url
  end
end
