Rails.application.routes.draw do
  devise_for :users
  root 'daily_menus#index'
  post 'orders/new' => 'orders#new'
  post'orders/order_print/:id' => 'orders#order_print'
  post 'products/hyoji' => 'products#hyoji'
  post "products/henkan" => "products#henkan"
  post'materials/include_update' => 'materials#include_update'
  post "versions/:id/revert" => "versions#revert", :as => "revert_version"
  post'menus/include_update' => 'menus#include_update'
  post 'materials/change_additives' => 'materials#change_additives'
  get '/kpi' => 'application#kpi'
  get '/product_report' => 'application#product_report'

  resources :kurumesi_orders do
    collection do
      get :test
      get :date
      get :print_preparation
      get :print_preparation_roma
      get :receipt
      post :print_receipt
      get :invoice
      post :print_invoice
      get :manufacturing_sheet
      get :loading_sheet
      get :material_preparation
      get :today_check
      get :paper_print
      get :print_receipts
    end
  end
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
      post :print
      get :picture_book
      get :get_menu_cost_price
      get :serving_kana
      get :serving
      get :recipe_romaji
      get :get_products
      get :input_name_get_products
      get :get_by_category
      post :print_preparation
      get :new_band
    end
  end
  resources :tops
  resources :kurumesi_admin_datas do
    collection do
      get :monthly
      get :daily
      get :analize
    end
  end

  resources :vendors
  resources :materials do
    collection do
      get :include_material
      get :used_check
    end
  end
  resources :orders do
    collection do
      get :send_order_fax
      get :preparation_all
      get :monthly
      get :products_pdfs
      get :material_info
      get :get_management_id
      get :check_management_id
      get :print_all
      post :material_reload
    end
  end
  resources :daily_menus do
    collection do
      get :preparation_all
      get :products_pdfs
      get :recipes_roma
      get :print_preparation
    end
  end
  resources :cooking_rices do
    collection do
      get :date
      get :rice_sheet
    end
  end
  resources :versions
  resources :food_additives
  resources :stocks do
    collection do
      get :monthly_inventory
      get :mobile_inventory
      get :history
      get :material_info
      get :inventory
      put :inventory_update
      get :inventory_sheet
    end
  end
  resources :storage_locations
  resources :kurumesi_mails
  resources :brands
end
