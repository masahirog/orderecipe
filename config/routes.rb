Rails.application.routes.draw do
  root 'top#index'
  resources :materials
  resources :top
  resources :products
  resources :menus

end
