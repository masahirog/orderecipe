Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'top#index'
  get 'menus/get_cost_price/:id' => 'menus#get_cost_price'
  resources :menus
  resources :products
  resources :tops
  resources :vendors
  resources :materials

end
