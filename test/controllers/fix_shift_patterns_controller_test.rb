require 'test_helper'

class FixShiftPatternsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @fix_shift_pattern = fix_shift_patterns(:one)
  end

  test "should get index" do
    get fix_shift_patterns_url
    assert_response :success
  end

  test "should get new" do
    get new_fix_shift_pattern_url
    assert_response :success
  end

  test "should create fix_shift_pattern" do
    assert_difference('FixShiftPattern.count') do
      post fix_shift_patterns_url, params: { fix_shift_pattern: {  } }
    end

    assert_redirected_to fix_shift_pattern_url(FixShiftPattern.last)
  end

  test "should show fix_shift_pattern" do
    get fix_shift_pattern_url(@fix_shift_pattern)
    assert_response :success
  end

  test "should get edit" do
    get edit_fix_shift_pattern_url(@fix_shift_pattern)
    assert_response :success
  end

  test "should update fix_shift_pattern" do
    patch fix_shift_pattern_url(@fix_shift_pattern), params: { fix_shift_pattern: {  } }
    assert_redirected_to fix_shift_pattern_url(@fix_shift_pattern)
  end

  test "should destroy fix_shift_pattern" do
    assert_difference('FixShiftPattern.count', -1) do
      delete fix_shift_pattern_url(@fix_shift_pattern)
    end

    assert_redirected_to fix_shift_patterns_url
  end
end
