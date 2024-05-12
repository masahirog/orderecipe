require 'test_helper'

class CommonProductPartsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @common_product_part = common_product_parts(:one)
  end

  test "should get index" do
    get common_product_parts_url
    assert_response :success
  end

  test "should get new" do
    get new_common_product_part_url
    assert_response :success
  end

  test "should create common_product_part" do
    assert_difference('CommonProductPart.count') do
      post common_product_parts_url, params: { common_product_part: {  } }
    end

    assert_redirected_to common_product_part_url(CommonProductPart.last)
  end

  test "should show common_product_part" do
    get common_product_part_url(@common_product_part)
    assert_response :success
  end

  test "should get edit" do
    get edit_common_product_part_url(@common_product_part)
    assert_response :success
  end

  test "should update common_product_part" do
    patch common_product_part_url(@common_product_part), params: { common_product_part: {  } }
    assert_redirected_to common_product_part_url(@common_product_part)
  end

  test "should destroy common_product_part" do
    assert_difference('CommonProductPart.count', -1) do
      delete common_product_part_url(@common_product_part)
    end

    assert_redirected_to common_product_parts_url
  end
end
