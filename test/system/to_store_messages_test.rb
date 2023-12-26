require "application_system_test_case"

class ToStoreMessagesTest < ApplicationSystemTestCase
  setup do
    @to_store_message = to_store_messages(:one)
  end

  test "visiting the index" do
    visit to_store_messages_url
    assert_selector "h1", text: "To Store Messages"
  end

  test "creating a To store message" do
    visit to_store_messages_url
    click_on "New To Store Message"

    click_on "Create To store message"

    assert_text "To store message was successfully created"
    click_on "Back"
  end

  test "updating a To store message" do
    visit to_store_messages_url
    click_on "Edit", match: :first

    click_on "Update To store message"

    assert_text "To store message was successfully updated"
    click_on "Back"
  end

  test "destroying a To store message" do
    visit to_store_messages_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "To store message was successfully destroyed"
  end
end
