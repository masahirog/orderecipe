Rails.application.routes.draw do

  namespace :vendor do
    resources :material_vendor_stocks do
      collection do
        get :material
      end
    end
    resources :orders do
      collection do
        post :status_change
      end
    end
  end

  namespace :crew do
    root 'store_daily_menus#index'
    get '/products/ikkatsu' => 'products#ikkatsu'
    resources :store_daily_menus do
      collection do
        get :menu_information
      end
    end
    resources :stores
    resources :products
    resources :orders do
      collection do
        get :sky_monthly
        get :monthly_data
        get :send_order_fax
        get :preparation_all
        get :monthly
        get :products_pdfs
        get :material_info
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
  root 'analyses#kpi'
  get '/list' => 'application#list'
  get '/shibataya' => 'application#shibataya'
  get '/shibataya_orders' => 'application#shibataya_orders'
  get '/shibataya_howto' => 'application#shibataya_howto'
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
  resources :common_product_parts do
    collection do
      get :get_common_product_part
    end
  end
  resources :item_expiration_dates
  resources :item_store_stocks do
    collection do
      get :stores
      get :items
    end
  end
  resources :buppan_schedules
  resources :manual_directories
  resources :material_vendor_stocks do
    collection do
      get :material
    end
  end
  resources :tasks do
    put :sort
  end
  
  get "working_hour_work_types/working_hour_change" => "working_hour_work_types#working_hour_change"
  get "working_hour_work_types/time_change" => "working_hour_work_types#time_change"
  resources :pre_orders do
    collection do
      get :daily
      get :monthly
    end
  end
  resources :working_hours do
    collection do
      get :detail
      get :result
      get :daily
      get :position_daily
      get :monthly
      post :create_work_times
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
  resources :temporary_product_menus do
    collection do
      post :ikkatsu_update
      get :menu_date
    end
  end
  resources :items do
    collection do
      get :store_order
      get :get_vendor_items
      get :get_item
      get :store
      get :stocks
    end
  end
  resources :item_orders
  resources :working_hour_work_types
  resources :work_types do
    collection do
      post :row_order_update
    end
  end
  resources :item_vendors
  resources :item_types
  resources :item_varieties
  resources :daily_items do
    collection do
      get :loading_sheet
      get :label
      get :calendar
      post :barcode_csv
      post :store_barcode_csv
      get :monthly
      get :vendor
    end
  end
  resources :to_store_messages
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
      get :date_attendance
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
      get :kitchen_kpi
      get :kpi
      get :bumon_sales
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
      get :vegetable_time_sales
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
  resources :food_ingredients do
    collection do
      get :reflect_seibun
    end
  end

  resources :menus do
    put :sort
    collection do
      post :print
      get :get_material
      get :get_food_ingredient
      get :get_cost_price
      get :food_ingredient_search
    end
  end
  resources :products do
    collection do
      get :include_menu
      get :price_card
      get :store_price_card
      get :edit_bb
      get :black_board
      get :download
      post :print
      get :get_menu_cost_price
      get :serving_kana
      get :serving
      get :get_product
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
      get :reflect_seibun
      get :scan
      get :used_products
      get :materials_used_amount
      post :material_cut_patterns_once_update
      get :cut_patterns
      get :all_cut_patterns
      get :monthly_used_amount
      get :include_material
      get :used_check
      get :get_material
    end
  end
  resources :orders do
    collection do
      get :sky_monthly
      get :monthly_data
      get :suriho
      get :bejihan_store_orders_list
      get :send_order_fax
      get :send_order_mail
      get :preparation_all
      get :monthly
      get :products_pdfs
      get :material_info
      get :print_all
      post :material_reload
      get :deliveried_list
    end
  end
  resources :daily_menus do
    collection do
      get :kpi
      get :serving_list
      get :description
      get :monthly_menus
      get :day_menus
      post :bulk_update
      get :schedule
      get :barcode
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
  resources :versions
  resources :food_additives
  resources :stocks do
    collection do
      get :scan
      get :store_inventory
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
  resources :brands
  resources :serving_plates
  resources :stores do
    collection do
      get :materials
    end
  end
  resources :store_daily_menus do
    collection do
      get :ou_menu_update
      get :budget
      post :budget_update
      get :ikkatsu
      post :input_multi_number
      get :input_manufacturing_number
      get :once_edit
      get :once_update
      post :upload_number
      post :once_update_number
      post :label
      post :bento_label
    end
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
