Rails.application.routes.draw do
  namespace :crew do
    get '/products' => 'products#index'
    get '/product/:id' => 'products#show'
    post'products/description_update' => 'products#description_update'

  end

  namespace :store do
    resources :store_daily_menus do
      collection do
          post :sales_upload
      end
    end
    resources :products do
      collection do
        get :download
      end
    end
  end
  devise_for :users
  root 'analyses#summary'
  get '/outside_view' => 'application#outside_view'
  post 'orders/new' => 'orders#new'
  post'orders/order_print/:id' => 'orders#order_print'
  post "products/henkan" => "products#henkan"
  post'materials/include_update' => 'materials#include_update'
  post "versions/:id/revert" => "versions#revert", :as => "revert_version"
  post'menus/include_update' => 'menus#include_update'
  post 'materials/change_additives' => 'materials#change_additives'
  resources :default_shifts do
    collection do
      post :create_frame
    end
  end
  resources :refund_supports
  resources :shift_frames
  resources :groups
  resources :fix_shift_patterns
  resources :material_store_orderables
  resources :shifts do
    collection do
      post :reflect_default_shifts
      get :store
      get :jobcan_upload
      get :once_update
      get :get_fix_shift_pattern
      get :check
      post :create_frame
      get :staff_edit
    end
  end
  resources :staffs do
    collection do
      post :row_order_update
    end
  end
  resources :tasks do
    collection do
      get :store
    end
  end
  resources :task_templates do
    collection do
      post :hand_reflect
    end
  end
  resources :sales_reports
  resources :containers
  resources :product_sales_potentials do
    collection do
      post :reflesh
    end
  end
  resources :analysis_products
  resources :analyses do
    collection do
      post :update_sales_data_smaregi_members
      post :onceupload
      get :sales
      get :member
      get :product
      get :repeat
      get :feedback

      get :smaregi_member_csv
      post :upload_smaregi_members
      get :member
      get :orders
      get :smaregi_members
      post :recalculate_potential
      get :store_products_sales
      get :store_product_sales
      get :summary
      post :products
      post :smaregi_trading_history_totalling
      get :date
      post :bulk_delete_analysis_products
    end
  end
  resources :smaregi_trading_histories do
    collection do
      post :upload_salesdatas
      get :analysis_data
      post :bulk_delete
    end
  end

  resources :kurumesi_orders do
    collection do
      get :sources
      get :delivery_note
      get :collation_sheet
      get :mail_check
      get :test
      get :date
      get :print_preparation
      get :print_preparation_roma
      get :receipt
      post :print_receipt
      get :accounting_copy
      get :invoice
      post :print_invoice
      get :manufacturing_sheet
      get :loading_sheet
      get :material_preparation
      get :today_check
      get :paper_print
      get :print_receipts
      get :equipment
      get :make_order
    end
  end
  resources :menus do
    put :sort
    collection do
      get :print
      get :get_material
      get :get_food_ingredient
      get :include_menu
      get :get_cost_price
      get :food_ingredient_search
    end
  end
  resources :products do
    collection do
      get :download
      get :bejihan_ss_cost_sync
      post :print
      get :get_menu_cost_price
      get :serving_kana
      get :serving
      get :get_product
      # get :recipe_romaji
      get :get_products
      get :input_name_get_products
      post :print_preparation
      get :new_band
      get :get_menu
    end
  end
  resources :tops
  resources :order_materials
  resources :vendors do
    collection do
      get :monthly_used_amount
    end
  end
  resources :customer_opinions
  resources :materials do
    collection do
      post :material_cut_patterns_once_update
      get :cut_patterns
      get :all_cut_patterns
      get :monthly_used_amount
      get :include_material
      get :used_check
    end
  end
  resources :orders do
    collection do
      get :bejihan_store_orders_list
      get :send_order_fax
      get :preparation_all
      get :monthly
      get :products_pdfs
      get :material_info
      get :get_management_id
      get :check_management_id
      get :print_all
      post :material_reload
      get :deliveried_list
    end
  end
  resources :daily_menus do
    collection do
      get :cook_check
      post :once_change_numbers
      get :cut_list
      get :kiridasi
      get :ikkatsu_edit
      get :cook_on_the_day
      post :create_1month
      post :upload_menu
      post :once_store_reflect
      get :store_reflect
      get :copy
      get :material_preparation
      get :preparation_all
      get :products_pdfs
      get :recipes_roma
      get :print_preparation
      get :sources
      get :loading
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
      get :outside_view
      get :material_search
      get :monthly_inventory
      get :mobile_inventory
      get :history
      get :material_info
      get :inventory
      put :inventory_update
      get :inventory_sheet
      get :alert
      post :update_monthly_stocks
      post :upload_inventory_csv
    end
  end
  resources :kurumesi_mails
  resources :brands
  resources :serving_plates
  resources :stores do
    collection do
      get :materials
    end
  end
  resources :store_daily_menus do
    collection do
      get :barcode
      get :description
      get :ikkatsu
      post :input_multi_number
      get :input_manufacturing_number
      get :once_edit
      get :once_update
      post :upload_number
      post :once_update_number
      get :stock
    end
  end
  resources :kaizen_lists
end
