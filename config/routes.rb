Rails.application.routes.draw do
  devise_for :users

  root 'daily_menus#index'
  post 'products/print' => 'products#print'
  post 'products/print_test' => 'products#print_test'
  post 'orders/new' => 'orders#new'
  post'orders/order_print/:id' => 'orders#order_print'
  post 'products/hyoji' => 'products#hyoji'
  post "products/henkan" => "products#henkan"
  post'materials/include_update' => 'materials#include_update'
  post "versions/:id/revert" => "versions#revert", :as => "revert_version"
  post'menus/include_update' => 'menus#include_update'
  post'orders/order_print_all/:id' => 'orders#order_print_all'
  post 'materials/change_additives' => 'materials#change_additives'
  # get 'menus/print/:id' => 'menus#print'
  # get 'menus/get_food_ingredient' => 'menus#get_food_ingredient'
  # get 'menus/include_menu/:id' => 'menus#include_menu'
  # get 'menus/get_cost_price/:id' => 'menus#get_cost_price'
  # get 'menus/food_ingredient_search' => 'menus/food_ingredient_search'
  # get 'products/new_band/:id' => 'products#new_band'
  # get 'products/get_menu_cost_price/:id' => 'products#get_menu_cost_price'
  # get 'products/serving_detail/:id' => 'products#serving_detail'
  # get 'products/serving_detail_en/:id' => 'products#serving_detail_en'
  # post 'products/serving_detail_en' => 'products#serving_detail_en'
  # get 'products/get_products' => 'products#get_products'
  # get 'products/input_name_get_products' => 'products#input_name_get_products'
  # get 'orders/material_info/:id' => 'orders#material_info'
  # get 'orders/get_bento_id' => 'orders#get_bento_id'
  # get 'orders/check_bento_id' => 'orders#check_bento_id'
  # get 'products/get_by_category' => 'products#get_by_category'
  # get 'products/preparation_all/:id' => 'products#preparation_all'
  # get 'products/print_test_all/:id' => 'products#print_test_all'
  # get 'materials/include_material/:id' => 'materials#include_material'
  # get 'stocks/material_info/:id' => 'stocks#material_info'
  # get 'materials/search' => 'materials#search'
  # get 'orders/monthly' => 'orders#monthly'


  resources :menus do
    put :sort
    collection do
      get :print
      get :get_food_ingredient
      get :include_menu
      get :get_cost_price
      get :food_ingredient_search
    end
  end
  resources :products do
    collection do
      get :picture_book
      get :get_menu_cost_price
      get :serving_detail
      get :serving_detail_en
      get :get_products
      get :input_name_get_products
      get :get_by_category
      get :preparation_all
      get :print_test_all
      get :new_band
    end
  end
  resources :tops
  resources :vendors
  resources :materials do
    collection do
      get :include_material
      get :search
    end
  end
  resources :orders do
    collection do
      get :monthly
      get :products_pdfs
      get :material_info
      get :get_bento_id
      get :check_bento_id
    end
  end
  resources :daily_menus do
    collection do
      get :products_pdfs
    end
  end

  resources :versions
  resources :food_additives
  resources :stocks do
    collection do
      get :material_info
    end
  end
  resources :storage_locations
end
