require "application_system_test_case"

class TaskStaffsTest < ApplicationSystemTestCase
  setup do
    @task_staff = task_staffs(:one)
  end

  test "visiting the index" do
    visit task_staffs_url
    assert_selector "h1", text: "Task Staffs"
  end

  test "creating a Task staff" do
    visit task_staffs_url
    click_on "New Task Staff"

    click_on "Create Task staff"

    assert_text "Task staff was successfully created"
    click_on "Back"
  end

  test "updating a Task staff" do
    visit task_staffs_url
    click_on "Edit", match: :first

    click_on "Update Task staff"

    assert_text "Task staff was successfully updated"
    click_on "Back"
  end

  test "destroying a Task staff" do
    visit task_staffs_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Task staff was successfully destroyed"
  end
end
