require 'test_helper'

class ShiftFramesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @shift_frame = shift_frames(:one)
  end

  test "should get index" do
    get shift_frames_url
    assert_response :success
  end

  test "should get new" do
    get new_shift_frame_url
    assert_response :success
  end

  test "should create shift_frame" do
    assert_difference('ShiftFrame.count') do
      post shift_frames_url, params: { shift_frame: {  } }
    end

    assert_redirected_to shift_frame_url(ShiftFrame.last)
  end

  test "should show shift_frame" do
    get shift_frame_url(@shift_frame)
    assert_response :success
  end

  test "should get edit" do
    get edit_shift_frame_url(@shift_frame)
    assert_response :success
  end

  test "should update shift_frame" do
    patch shift_frame_url(@shift_frame), params: { shift_frame: {  } }
    assert_redirected_to shift_frame_url(@shift_frame)
  end

  test "should destroy shift_frame" do
    assert_difference('ShiftFrame.count', -1) do
      delete shift_frame_url(@shift_frame)
    end

    assert_redirected_to shift_frames_url
  end
end
