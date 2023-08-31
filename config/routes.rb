Rails.application.routes.draw do
  namespace :crew do
    root 'store_daily_menus#index'
    get '/products/ikkatsu' => 'products#ikkatsu'
    resources :store_daily_menus
    resources :stores
    resources :products
    resources :orders do
      collection do
        get :monthly_data
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
  resources :tasks do
    put :sort
  end
  resources :working_hours do
    collection do
      get :result
      post :create_work_times
      get :staff_input
      post :upload_data
    end
  end
  resources :tastings do
    collection do
      get :weekly
    end
  end
  resources :temporary_menu_materials do
    collection do
      post :ikkatsu_update
      get :material_date
    end
  end
  resources :store_daily_menu_detail_histories
  resources :store_daily_menu_details
  resources :task_comments
  resources :task_staffs
  resources :refund_supports
  resources :shift_frames
  resources :groups
  resources :fix_shift_patterns
  resources :material_store_orderables
  resources :shifts do
    collection do
      post :csv_once_update
      get :transportation_expenses
      get :get_fix_shift_pattern
      get :fixed
      post :once_update_fixed
      post :reflect_default_shifts
      get :store
      get :once_update
      get :get_fix_shift_pattern
      post :create_frame
      get :staff_edit
      get :mf
      post :download_mf_csv
    end
  end
  resources :staffs do
    collection do
      post :row_order_update
    end
  end
  resources :reminders do
    collection do
      get :store
      get :clean
    end
  end
  resources :reminder_templates do
    collection do
      post :hand_reflect
    end
  end
  resources :sales_reports do
    collection do
      get :select_store
    end
  end
  resources :containers
  resources :product_sales_potentials do
    collection do
      post :reflesh
    end
  end
  resources :analysis_products
  resources :analyses do
    collection do
      get :loss
      post :loss_update
      get :monthly_timezone
      post :reload_product_repeat
      get :product_repeat
      get :ltv_data
      get :progress
      get :gyusuji
      get :labor
      get :timezone_sales
      get :stores
      get :staffs
      post :update_sales_data_smaregi_members
      post :onceupload
      get :sales
      get :member
      get :product
      get :repeat
      get :feedback
      get :product_sales
      get :vegetable_sales
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
      get :member
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
      get :monthly_data
      get :suriho
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
      post :stock_reload
      post :store_input_able
      post :store_input_disable
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
      post :make_this_month
      get :monthly
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
      get :budget
      post :budget_update
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

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
