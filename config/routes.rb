Rails.application.routes.draw do
  devise_for :users
  as :user do
    get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
    put 'users' => 'devise/registrations#update', :as => 'user_registration'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'top#index'
  get 'menus/get_cost_price/:id' => 'menus#get_cost_price'
  get 'products/get_menu_cost_price/:id' => 'products#get_menu_cost_price'
  get 'products/serving_detail/:id' => 'products#serving_detail'
  get 'products/serving_detail_en/:id' => 'products#serving_detail_en'
  post 'products/print' => 'products#print'
  get 'products/get_products' => 'products#get_products'
  get 'products/input_name_get_products' => 'products#input_name_get_products'
  post 'orders/new' => 'orders#new'
  get 'orders/material_info/:id' => 'orders#material_info'
  get 'orders/get_bento_id' => 'orders#get_bento_id'
  get 'orders/check_bento_id' => 'orders#check_bento_id'
  post'orders/order_print/:id' => 'orders#order_print'
  get 'products/get_by_category' => 'products#get_by_category'
  get 'products/preparation_all/:id' => 'products#preparation_all'
  get 'products/product_pdf_all/:id' => 'products#product_pdf_all'
  post 'products/hyoji' => 'products#hyoji'
  post "products/henkan" => "products#henkan"
  get 'materials/include_material/:id' => 'materials#include_material'
  post'materials/include_update' => 'materials#include_update'
  post "versions/:id/revert" => "versions#revert", :as => "revert_version"
  get 'menus/include_menu/:id' => 'menus#include_menu'
  post'menus/include_update' => 'menus#include_update'
  get 'menus/print/:id' => 'menus#print'
  post'orders/order_print_all/:id' => 'orders#order_print_all'
  post 'materials/change_additives' => 'materials#change_additives'
  get 'stocks/material_info/:id' => 'stocks#material_info'
  get 'products/show_all' => 'products#show_all'


  resources :menus
  resources :menus do
    put :sort
  end
  resources :products
  resources :tops
  resources :vendors
  resources :materials
  resources :orders
  resources :versions
  resources :food_additives
  resources :stocks
end
