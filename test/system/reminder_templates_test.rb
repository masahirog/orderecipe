require "application_system_test_case"

class ReminderTemplatesTest < ApplicationSystemTestCase
  setup do
    @reminder_template = reminder_templates(:one)
  end

  test "visiting the index" do
    visit reminder_templates_url
    assert_selector "h1", text: "Reminder Templates"
  end

  test "creating a Reminder Template" do
    visit reminder_templates_url
    click_on "New Reminder Template"

    click_on "Create Reminder Template"

    assert_text "Reminder Template was successfully created"
    click_on "Back"
  end

  test "updating a Reminder Template" do
    visit reminder_templates_url
    click_on "Edit", match: :first

    click_on "Update Reminder Template"

    assert_text "Reminder Template was successfully updated"
    click_on "Back"
  end

  test "destroying a Reminder Template" do
    visit reminder_templates_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Reminder Template was successfully destroyed"
  end
end
