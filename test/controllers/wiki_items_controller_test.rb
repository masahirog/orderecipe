require 'test_helper'

class WikiItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @wiki_item = wiki_items(:one)
  end

  test "should get index" do
    get wiki_items_url
    assert_response :success
  end

  test "should get new" do
    get new_wiki_item_url
    assert_response :success
  end

  test "should create wiki_item" do
    assert_difference('WikiItem.count') do
      post wiki_items_url, params: { wiki_item: {  } }
    end

    assert_redirected_to wiki_item_url(WikiItem.last)
  end

  test "should show wiki_item" do
    get wiki_item_url(@wiki_item)
    assert_response :success
  end

  test "should get edit" do
    get edit_wiki_item_url(@wiki_item)
    assert_response :success
  end

  test "should update wiki_item" do
    patch wiki_item_url(@wiki_item), params: { wiki_item: {  } }
    assert_redirected_to wiki_item_url(@wiki_item)
  end

  test "should destroy wiki_item" do
    assert_difference('WikiItem.count', -1) do
      delete wiki_item_url(@wiki_item)
    end

    assert_redirected_to wiki_items_url
  end
end
