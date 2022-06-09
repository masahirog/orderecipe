require 'test_helper'

class ReminderTemplatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @reminder_template = reminder_templates(:one)
  end

  test "should get index" do
    get reminder_templates_url
    assert_response :success
  end

  test "should get new" do
    get new_reminder_template_url
    assert_response :success
  end

  test "should create reminder_template" do
    assert_difference('ReminderTemplate.count') do
      post reminder_templates_url, params: { reminder_template: {  } }
    end

    assert_redirected_to reminder_template_url(ReminderTemplate.last)
  end

  test "should show reminder_template" do
    get reminder_template_url(@reminder_template)
    assert_response :success
  end

  test "should get edit" do
    get edit_reminder_template_url(@reminder_template)
    assert_response :success
  end

  test "should update reminder_template" do
    patch reminder_template_url(@reminder_template), params: { reminder_template: {  } }
    assert_redirected_to reminder_template_url(@reminder_template)
  end

  test "should destroy reminder_template" do
    assert_difference('ReminderTemplate.count', -1) do
      delete reminder_template_url(@reminder_template)
    end

    assert_redirected_to reminder_templates_url
  end
end
