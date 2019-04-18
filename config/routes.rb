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
      get :serving_kana
      get :recipe_romaji
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
      get :products_pdfs_roma
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
