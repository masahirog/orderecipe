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
  get 'products/print/:id' => 'products#print'
  post 'orders/new' => 'orders#new'
  post 'orders/confirm' => 'orders#confirm'
  get 'orders/material_info/:id' => 'orders#material_info'
  post'orders/order_print/:id' => 'orders#order_print'
  resources :menus
  resources :products
  resources :tops
  resources :vendors
  resources :materials
  resources :orders
end
