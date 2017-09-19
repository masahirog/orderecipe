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
  get 'products/menu_search' => 'products#menu_search'
  get 'menus/material_search' => 'menus#material_search'
  get 'menus/material_exist' => 'menus#material_exist'
  get 'products/menu_exist' => 'products#menu_exist'
  get  '/typeahead' => 'menus#typeahead_action'
  resources :menus
  resources :products
  resources :tops
  resources :vendors
  resources :materials
end
