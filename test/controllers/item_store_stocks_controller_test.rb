require 'test_helper'

class ItemStoreStocksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @item_store_stock = item_store_stocks(:one)
  end

  test "should get index" do
    get item_store_stocks_url
    assert_response :success
  end

  test "should get new" do
    get new_item_store_stock_url
    assert_response :success
  end

  test "should create item_store_stock" do
    assert_difference('ItemStoreStock.count') do
      post item_store_stocks_url, params: { item_store_stock: {  } }
    end

    assert_redirected_to item_store_stock_url(ItemStoreStock.last)
  end

  test "should show item_store_stock" do
    get item_store_stock_url(@item_store_stock)
    assert_response :success
  end

  test "should get edit" do
    get edit_item_store_stock_url(@item_store_stock)
    assert_response :success
  end

  test "should update item_store_stock" do
    patch item_store_stock_url(@item_store_stock), params: { item_store_stock: {  } }
    assert_redirected_to item_store_stock_url(@item_store_stock)
  end

  test "should destroy item_store_stock" do
    assert_difference('ItemStoreStock.count', -1) do
      delete item_store_stock_url(@item_store_stock)
    end

    assert_redirected_to item_store_stocks_url
  end
end
