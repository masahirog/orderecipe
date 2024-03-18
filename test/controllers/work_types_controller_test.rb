require 'test_helper'

class WorkTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @work_type = work_types(:one)
  end

  test "should get index" do
    get work_types_url
    assert_response :success
  end

  test "should get new" do
    get new_work_type_url
    assert_response :success
  end

  test "should create work_type" do
    assert_difference('WorkType.count') do
      post work_types_url, params: { work_type: {  } }
    end

    assert_redirected_to work_type_url(WorkType.last)
  end

  test "should show work_type" do
    get work_type_url(@work_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_work_type_url(@work_type)
    assert_response :success
  end

  test "should update work_type" do
    patch work_type_url(@work_type), params: { work_type: {  } }
    assert_redirected_to work_type_url(@work_type)
  end

  test "should destroy work_type" do
    assert_difference('WorkType.count', -1) do
      delete work_type_url(@work_type)
    end

    assert_redirected_to work_types_url
  end
end
