require "application_system_test_case"

class ShiftFramesTest < ApplicationSystemTestCase
  setup do
    @shift_frame = shift_frames(:one)
  end

  test "visiting the index" do
    visit shift_frames_url
    assert_selector "h1", text: "Shift Frames"
  end

  test "creating a Shift frame" do
    visit shift_frames_url
    click_on "New Shift Frame"

    click_on "Create Shift frame"

    assert_text "Shift frame was successfully created"
    click_on "Back"
  end

  test "updating a Shift frame" do
    visit shift_frames_url
    click_on "Edit", match: :first

    click_on "Update Shift frame"

    assert_text "Shift frame was successfully updated"
    click_on "Back"
  end

  test "destroying a Shift frame" do
    visit shift_frames_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Shift frame was successfully destroyed"
  end
end
