require 'test_helper'

class ItemVarietiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @item_variety = item_varieties(:one)
  end

  test "should get index" do
    get item_varieties_url
    assert_response :success
  end

  test "should get new" do
    get new_item_variety_url
    assert_response :success
  end

  test "should create item_variety" do
    assert_difference('ItemVariety.count') do
      post item_varieties_url, params: { item_variety: {  } }
    end

    assert_redirected_to item_variety_url(ItemVariety.last)
  end

  test "should show item_variety" do
    get item_variety_url(@item_variety)
    assert_response :success
  end

  test "should get edit" do
    get edit_item_variety_url(@item_variety)
    assert_response :success
  end

  test "should update item_variety" do
    patch item_variety_url(@item_variety), params: { item_variety: {  } }
    assert_redirected_to item_variety_url(@item_variety)
  end

  test "should destroy item_variety" do
    assert_difference('ItemVariety.count', -1) do
      delete item_variety_url(@item_variety)
    end

    assert_redirected_to item_varieties_url
  end
end
