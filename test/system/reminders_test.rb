require "application_system_test_case"

class RemindersTest < ApplicationSystemTestCase
  setup do
    @reminder = reminders(:one)
  end

  test "visiting the index" do
    visit reminders_url
    assert_selector "h1", text: "reminders"
  end

  test "creating a reminder" do
    visit reminders_url
    click_on "New reminder"

    click_on "Create reminder"

    assert_text "Reminder was successfully created"
    click_on "Back"
  end

  test "updating a reminder" do
    visit reminders_url
    click_on "Edit", match: :first

    click_on "Update reminder"

    assert_text "Reminder was successfully updated"
    click_on "Back"
  end

  test "destroying a reminder" do
    visit reminders_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Reminder was successfully destroyed"
  end
end
