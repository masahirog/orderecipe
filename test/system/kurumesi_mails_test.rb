require "application_system_test_case"

class KurumesiMailsTest < ApplicationSystemTestCase
  setup do
    @kurumesi_mail = kurumesi_mails(:one)
  end

  test "visiting the index" do
    visit kurumesi_mails_url
    assert_selector "h1", text: "Kurumesi Mails"
  end

  test "creating a Kurumesi mail" do
    visit kurumesi_mails_url
    click_on "New Kurumesi Mail"

    click_on "Create Kurumesi mail"

    assert_text "Kurumesi mail was successfully created"
    click_on "Back"
  end

  test "updating a Kurumesi mail" do
    visit kurumesi_mails_url
    click_on "Edit", match: :first

    click_on "Update Kurumesi mail"

    assert_text "Kurumesi mail was successfully updated"
    click_on "Back"
  end

  test "destroying a Kurumesi mail" do
    visit kurumesi_mails_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Kurumesi mail was successfully destroyed"
  end
end
