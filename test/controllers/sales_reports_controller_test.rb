require 'test_helper'

class SalesReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @sales_report = sales_reports(:one)
  end

  test "should get index" do
    get sales_reports_url
    assert_response :success
  end

  test "should get new" do
    get new_sales_report_url
    assert_response :success
  end

  test "should create sales_report" do
    assert_difference('SalesReport.count') do
      post sales_reports_url, params: { sales_report: {  } }
    end

    assert_redirected_to sales_report_url(SalesReport.last)
  end

  test "should show sales_report" do
    get sales_report_url(@sales_report)
    assert_response :success
  end

  test "should get edit" do
    get edit_sales_report_url(@sales_report)
    assert_response :success
  end

  test "should update sales_report" do
    patch sales_report_url(@sales_report), params: { sales_report: {  } }
    assert_redirected_to sales_report_url(@sales_report)
  end

  test "should destroy sales_report" do
    assert_difference('SalesReport.count', -1) do
      delete sales_report_url(@sales_report)
    end

    assert_redirected_to sales_reports_url
  end
end
