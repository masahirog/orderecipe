# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2024_05_30_003841) do

  create_table "analyses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "store_id"
    t.date "date"
    t.integer "total_sales_amount"
    t.integer "loss_amount"
    t.integer "labor_cost"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "transaction_count", default: 0, null: false
    t.integer "sixteen_transaction_count", default: 0, null: false
    t.integer "sixteen_sozai_sales_number", default: 0, null: false
    t.integer "total_sozai_sales_number", default: 0, null: false
    t.integer "discount_amount"
    t.integer "net_sales_amount"
    t.integer "tax_amount"
    t.integer "ex_tax_sales_amount"
    t.integer "store_sales_amount"
    t.integer "delivery_sales_amount"
    t.integer "used_point_amount"
    t.integer "used_coupon_amount"
    t.integer "store_daily_menu_id", null: false
    t.integer "vegetable_waste_amount", default: 0, null: false
    t.index ["date", "store_id"], name: "index_analyses_on_date_and_store_id", unique: true
  end

  create_table "analysis_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "analysis_id"
    t.integer "smaregi_bumon_id"
    t.integer "sales_number"
    t.integer "sales_amount"
    t.integer "discount_amount"
    t.integer "net_sales_amount"
    t.integer "ex_tax_sales_amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "loss_amount"
    t.index ["analysis_id", "smaregi_bumon_id"], name: "index_analysis_categories_on_analysis_id_and_smaregi_bumon_id", unique: true
    t.index ["analysis_id"], name: "index_analysis_categories_on_analysis_id"
  end

  create_table "analysis_products", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "analysis_id"
    t.integer "smaregi_shohin_id"
    t.text "smaregi_shohin_name"
    t.integer "smaregi_shohintanka"
    t.integer "product_id"
    t.integer "orderecipe_sell_price"
    t.float "cost_price"
    t.integer "manufacturing_number"
    t.integer "carry_over"
    t.integer "actual_inventory"
    t.integer "sales_number"
    t.integer "loss_number"
    t.integer "total_sales_amount"
    t.integer "loss_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sixteen_total_sales_number", default: 0, null: false
    t.boolean "exclusion_flag", default: false, null: false
    t.float "potential"
    t.integer "bumon_id"
    t.integer "bumon_mei"
    t.integer "discount_amount"
    t.integer "net_sales_amount"
    t.integer "ex_tax_sales_amount"
    t.float "discount_rate"
    t.boolean "loss_ignore", default: false, null: false
    t.integer "discount_number", default: 0
    t.float "nomination_rate", default: 0.0, null: false
    t.index ["analysis_id", "product_id"], name: "index_analysis_products_on_analysis_id_and_product_id", unique: true
    t.index ["analysis_id"], name: "index_analysis_products_on_analysis_id"
  end

  create_table "brands", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "group_id", null: false
    t.boolean "unused_flag", default: false, null: false
  end

  create_table "buppan_schedules", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.date "date"
    t.boolean "fixed_flag", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "memo"
  end

  create_table "common_product_parts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "unit", null: false
    t.string "memo"
    t.integer "container", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "loading_container", default: 0, null: false
    t.integer "loading_position", default: 0, null: false
    t.string "product_name"
  end

  create_table "containers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "group_id", null: false
    t.boolean "inversion_label_flag", default: true, null: false
  end

  create_table "customer_opinions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.date "date"
    t.integer "evaluation"
    t.integer "taste"
    t.integer "price"
    t.integer "service"
    t.bigint "receipt_number"
    t.text "content"
    t.string "mail"
    t.integer "store_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "daily_item_stores", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "daily_item_id"
    t.integer "store_id"
    t.integer "subordinate_amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "sell_price", default: 0, null: false
    t.integer "tax_including_sell_price", default: 0, null: false
  end

  create_table "daily_items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "date", null: false
    t.integer "purpose", null: false
    t.integer "item_id", null: false
    t.text "memo"
    t.integer "estimated_sales", default: 0, null: false
    t.integer "tax_including_estimated_sales", default: 0, null: false
    t.integer "purchase_price", default: 0, null: false
    t.integer "tax_including_purchase_price", default: 0, null: false
    t.integer "delivery_fee", default: 0, null: false
    t.integer "tax_including_delivery_fee", default: 0, null: false
    t.integer "subtotal_price", default: 0, null: false
    t.integer "tax_including_subtotal_price", default: 0, null: false
    t.integer "order_unit"
    t.integer "delivery_amount", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "sorting_memo"
    t.integer "order_unit_amount", default: 0, null: false
    t.integer "adjustment_subtotal", default: 0, null: false
  end

  create_table "daily_menu_details", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "daily_menu_id"
    t.bigint "product_id"
    t.integer "manufacturing_number", default: 0, null: false
    t.float "cost_price_per_product", default: 0.0, null: false
    t.integer "total_cost_price", default: 0, null: false
    t.integer "row_order", default: 0, null: false
    t.integer "serving_plate_id"
    t.boolean "signboard_flag", default: false, null: false
    t.boolean "window_pop_flag", default: false, null: false
    t.time "sold_outed"
    t.integer "for_single_item_number", default: 0, null: false
    t.integer "for_sub_item_number", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "adjustments", default: 0, null: false
    t.integer "sell_price", default: 0, null: false
    t.integer "paper_menu_number"
    t.boolean "change_flag", default: false, null: false
    t.index ["daily_menu_id", "paper_menu_number"], name: "index_daily_menu_details_on_daily_menu_id_and_paper_menu_number", unique: true
    t.index ["daily_menu_id", "product_id"], name: "index_daily_menu_details_on_daily_menu_id_and_product_id", unique: true
    t.index ["daily_menu_id"], name: "index_daily_menu_details_on_daily_menu_id"
    t.index ["product_id"], name: "index_daily_menu_details_on_product_id"
  end

  create_table "daily_menus", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "start_time", null: false
    t.integer "total_manufacturing_number", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sozai_manufacturing_number", default: 0, null: false
    t.boolean "stock_update_flag", default: false, null: false
    t.float "worktime"
  end

  create_table "default_shifts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "weekday"
    t.integer "store_id"
    t.integer "staff_id"
    t.integer "fix_shift_pattern_id"
    t.text "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.time "start_time"
    t.time "end_time"
    t.time "rest_start_time"
    t.time "rest_end_time"
  end

  create_table "fax_mails", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "order_id"
    t.integer "vendor_id"
    t.integer "status", default: 0
    t.string "subject"
    t.datetime "recieved"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fix_shift_pattern_shift_frames", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "fix_shift_pattern_id"
    t.integer "shift_frame_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fix_shift_pattern_stores", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "fix_shift_pattern_id", null: false
    t.integer "store_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["fix_shift_pattern_id", "store_id"], name: "index_uniq", unique: true
  end

  create_table "fix_shift_patterns", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "pattern_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "working_hour"
    t.time "start_time"
    t.time "end_time"
    t.integer "group_id"
    t.string "color_code", default: "#000000"
    t.string "bg_color_code", default: "#ffffff"
    t.boolean "unused_flag", default: false, null: false
    t.time "rest_start_time"
    t.time "rest_end_time"
  end

  create_table "food_additives", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "food_ingredients", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "food_group"
    t.integer "food_number"
    t.integer "index_number"
    t.string "name"
    t.string "complement"
    t.float "calorie", default: 0.0, null: false
    t.float "protein", default: 0.0, null: false
    t.float "lipid", default: 0.0, null: false
    t.float "carbohydrate", default: 0.0, null: false
    t.float "dietary_fiber", default: 0.0, null: false
    t.float "potassium", default: 0.0, null: false
    t.float "calcium", default: 0.0, null: false
    t.float "vitamin_b1", default: 0.0, null: false
    t.float "vitamin_b2", default: 0.0, null: false
    t.float "vitamin_c", default: 0.0, null: false
    t.float "salt", default: 0.0, null: false
    t.text "memo"
    t.float "magnesium", default: 0.0, null: false
    t.float "iron", default: 0.0, null: false
    t.float "zinc", default: 0.0, null: false
    t.float "copper", default: 0.0, null: false
    t.float "folic_acid", default: 0.0, null: false
    t.float "vitamin_d", default: 0.0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "task_slack_url"
  end

  create_table "item_expiration_dates", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "expiration_date", null: false
    t.bigint "item_id"
    t.integer "number"
    t.date "notice_date"
    t.boolean "done_flag", default: false, null: false
    t.text "memo"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["item_id"], name: "index_item_expiration_dates_on_item_id"
  end

  create_table "item_order_items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "item_order_id", null: false
    t.bigint "item_id", null: false
    t.string "order_quantity", default: "0", null: false
    t.string "memo"
    t.boolean "un_order_flag", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["item_id"], name: "index_item_order_items_on_item_id"
    t.index ["item_order_id", "item_id"], name: "index_item_order_items_on_item_order_id_and_item_id", unique: true
    t.index ["item_order_id"], name: "index_item_order_items_on_item_order_id"
  end

  create_table "item_orders", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.date "delivery_date", null: false
    t.text "memo"
    t.boolean "fixed_flag", default: false, null: false
    t.string "staff_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["store_id"], name: "index_item_orders_on_store_id"
  end

  create_table "item_store_stocks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "date"
    t.bigint "item_id", null: false
    t.bigint "store_id", null: false
    t.integer "unit", null: false
    t.integer "unit_price", null: false
    t.integer "stock", default: 0, null: false
    t.integer "stock_price", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["date", "item_id", "store_id"], name: "index_item_store_stocks_on_date_and_item_id_and_store_id", unique: true
    t.index ["item_id"], name: "index_item_store_stocks_on_item_id"
    t.index ["store_id"], name: "index_item_store_stocks_on_store_id"
  end

  create_table "item_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.integer "category"
    t.text "storage"
    t.text "display"
    t.text "feature"
    t.text "cooking"
    t.text "choice"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "item_varieties", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "item_type_id"
    t.string "name", null: false
    t.string "image"
    t.text "storage"
    t.text "display"
    t.text "feature"
    t.text "cooking"
    t.text "choice"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["item_type_id"], name: "index_item_varieties_on_item_type_id"
  end

  create_table "item_vendors", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "store_name"
    t.string "producer_name"
    t.string "area"
    t.integer "payment"
    t.string "bank_name"
    t.string "bank_store_name"
    t.string "bank_category"
    t.string "account_number"
    t.string "account_title"
    t.string "zip_code"
    t.string "address"
    t.string "tel"
    t.string "charge_person"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "unused_flag", default: false, null: false
    t.integer "sorting_base_id", default: 0, null: false
  end

  create_table "items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "item_variety_id"
    t.text "memo"
    t.boolean "reduced_tax_flag", default: true, null: false
    t.integer "sell_price", default: 0, null: false
    t.integer "tax_including_sell_price", default: 0, null: false
    t.integer "purchase_price", null: false
    t.integer "tax_including_purchase_price", null: false
    t.integer "unit", null: false
    t.bigint "item_vendor_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "smaregi_code"
    t.string "sales_life"
    t.integer "order_unit", null: false
    t.integer "order_unit_amount", null: false
    t.integer "stock_store_id"
    t.integer "order_lot", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.index ["item_variety_id"], name: "index_items_on_item_variety_id"
    t.index ["item_vendor_id"], name: "index_items_on_item_vendor_id"
  end

  create_table "manual_directories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "title"
    t.string "ancestry"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["ancestry"], name: "index_manual_directories_on_ancestry"
  end

  create_table "manuals", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "manual_directory_id", null: false
    t.text "content"
    t.string "picture"
    t.integer "row_order", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "material_cut_patterns", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "material_id", null: false
    t.string "name"
    t.integer "machine"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "roma_name"
  end

  create_table "material_food_additives", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "material_id", null: false
    t.integer "food_additive_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "material_store_orderables", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "material_id", null: false
    t.integer "store_id", null: false
    t.boolean "orderable_flag", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "order_criterion"
    t.boolean "mon", default: false, null: false
    t.boolean "tue", default: false, null: false
    t.boolean "wed", default: false, null: false
    t.boolean "thu", default: false, null: false
    t.boolean "fri", default: false, null: false
    t.boolean "sat", default: false, null: false
    t.boolean "sun", default: false, null: false
    t.date "last_inventory_date"
    t.index ["material_id", "store_id"], name: "index_material_store_orderables_on_material_id_and_store_id", unique: true
  end

  create_table "material_vendor_stocks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "material_id", null: false
    t.date "date", null: false
    t.integer "previous_end_day_stock", default: 0, null: false
    t.integer "end_day_stock", default: 0, null: false
    t.integer "shipping_amount"
    t.integer "new_stock_amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "estimated_amount"
    t.index ["date", "material_id"], name: "index_material_vendor_stocks_on_date_and_material_id", unique: true
  end

  create_table "materials", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "order_name"
    t.string "roma_name"
    t.float "recipe_unit_quantity"
    t.string "recipe_unit"
    t.float "recipe_unit_price"
    t.float "cost_price"
    t.integer "category"
    t.string "order_code"
    t.text "memo"
    t.boolean "unused_flag", default: false, null: false
    t.integer "vendor_id"
    t.string "order_unit"
    t.float "order_unit_quantity"
    t.text "allergy"
    t.boolean "vendor_stock_flag", default: true, null: false
    t.integer "delivery_deadline", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "accounting_unit", null: false
    t.integer "accounting_unit_quantity", null: false
    t.boolean "measurement_flag", default: false, null: false
    t.string "image"
    t.string "short_name"
    t.integer "storage_place", default: 0, null: false
    t.boolean "subdivision_able", default: false, null: false
    t.integer "group_id", null: false
    t.integer "target_material_id"
    t.date "price_update_date"
    t.string "jancode"
    t.integer "food_ingredient_id"
  end

  create_table "menu_cook_checks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "menu_id", null: false
    t.string "content", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "check_position", null: false
  end

  create_table "menu_last_processes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "menu_id", null: false
    t.string "content", default: "", null: false
    t.string "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "menu_materials", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "menu_id", null: false
    t.integer "material_id", null: false
    t.float "amount_used", default: 0.0, null: false
    t.string "preparation"
    t.integer "post"
    t.integer "row_order", default: 0, null: false
    t.float "gram_quantity"
    t.float "calorie", default: 0.0, null: false
    t.float "protein", default: 0.0, null: false
    t.float "lipid", default: 0.0, null: false
    t.float "carbohydrate", default: 0.0, null: false
    t.float "dietary_fiber", default: 0.0, null: false
    t.float "salt", default: 0.0, null: false
    t.integer "base_menu_material_id"
    t.boolean "source_flag", default: false, null: false
    t.integer "source_group"
    t.boolean "first_flag", default: false, null: false
    t.boolean "machine_flag", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "material_cut_pattern_id"
  end

  create_table "menu_processes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "menu_id"
    t.string "image"
    t.text "memo"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "menus", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "roma_name"
    t.text "cook_the_day_before"
    t.integer "category"
    t.text "serving_memo"
    t.float "cost_price"
    t.string "used_additives", default: "", null: false
    t.text "cook_on_the_day"
    t.string "image"
    t.integer "base_menu_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "short_name"
    t.integer "group_id", null: false
    t.float "calorie", default: 0.0, null: false
    t.float "protein", default: 0.0, null: false
    t.float "lipid", default: 0.0, null: false
    t.float "carbohydrate", default: 0.0, null: false
    t.float "dietary_fiber", default: 0.0, null: false
    t.float "salt", default: 0.0, null: false
  end

  create_table "monthly_stocks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.date "date"
    t.integer "item_number"
    t.integer "total_amount"
    t.integer "foods_amount"
    t.integer "equipments_amount"
    t.integer "expendables_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "store_id", null: false
    t.index ["date", "store_id"], name: "index_monthly_stocks_on_date_and_store_id", unique: true
  end

  create_table "order_materials", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "order_id"
    t.integer "material_id"
    t.string "order_quantity", default: "0", null: false
    t.float "calculated_quantity"
    t.string "order_material_memo"
    t.date "delivery_date"
    t.text "menu_name"
    t.boolean "un_order_flag", default: false, null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["material_id"], name: "index_order_materials_on_material_id"
    t.index ["order_id"], name: "index_order_materials_on_order_id"
    t.index ["un_order_flag"], name: "index_order_materials_on_un_order_flag"
  end

  create_table "order_products", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "product_id", null: false
    t.integer "serving_for"
    t.date "make_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "fixed_flag", default: false, null: false
    t.string "staff_name"
    t.integer "store_id"
    t.text "memo"
  end

  create_table "pre_order_products", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "pre_order_id", null: false
    t.bigint "product_id", null: false
    t.integer "order_num", default: 0, null: false
    t.integer "tax_including_sell_price", default: 0, null: false
    t.integer "subtotal", default: 0, null: false
    t.integer "welfare_price", default: 0, null: false
    t.integer "employee_discount", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["pre_order_id"], name: "index_pre_order_products_on_pre_order_id"
    t.index ["product_id"], name: "index_pre_order_products_on_product_id"
  end

  create_table "pre_orders", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.date "date", null: false
    t.time "recipient_time", null: false
    t.integer "employee_id"
    t.string "recipient_name"
    t.string "tel"
    t.integer "status", default: 0, null: false
    t.text "memo"
    t.integer "total", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["store_id"], name: "index_pre_orders_on_store_id"
  end

  create_table "product_bbs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "product_id", null: false
    t.string "image"
    t.text "memo"
    t.integer "staff_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "product_menus", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "menu_id", null: false
    t.integer "row_order", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_ozara_serving_informations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "row_order", default: 0, null: false
    t.string "image"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_pack_serving_informations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "row_order", default: 0, null: false
    t.string "image"
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "product_parts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "product_id", null: false
    t.string "name", default: "", null: false
    t.float "amount", default: 0.0, null: false
    t.string "unit", null: false
    t.string "memo"
    t.integer "container", default: 0, null: false
    t.boolean "sticker_print_flag", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "common_product_part_id"
    t.integer "loading_container", default: 0, null: false
    t.integer "loading_position", default: 0, null: false
    t.index ["common_product_part_id"], name: "index_product_parts_on_common_product_part_id"
  end

  create_table "product_sales_potentials", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "store_id", null: false
    t.integer "product_id", null: false
    t.integer "sales_potential", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "store_id"], name: "index_product_sales_potentials_on_product_id_and_store_id", unique: true
  end

  create_table "products", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.integer "sell_price", null: false
    t.text "description"
    t.text "contents"
    t.float "cost_price"
    t.string "image"
    t.integer "status", default: 1, null: false
    t.integer "brand_id"
    t.integer "product_category", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "bejihan_sozai_flag", default: false, null: false
    t.string "display_image"
    t.string "image_for_one_person"
    t.text "serving_infomation"
    t.string "food_label_name", null: false
    t.text "food_label_content"
    t.boolean "carryover_able_flag", default: false, null: false
    t.integer "main_serving_plate_id"
    t.integer "sub_serving_plate_id"
    t.integer "container_id"
    t.boolean "freezing_able_flag", default: false, null: false
    t.integer "sky_wholesale_price"
    t.string "sky_image"
    t.text "sky_serving_infomation"
    t.integer "group_id", null: false
    t.integer "sub_category"
    t.string "sky_split_information"
    t.boolean "bejihan_only_flag", default: false, null: false
    t.string "smaregi_code"
    t.boolean "warm_flag", default: false, null: false
    t.integer "tax_including_sell_price", null: false
    t.boolean "reduced_tax_flag", default: true, null: false
    t.boolean "half_able_flag", default: false, null: false
    t.string "sales_unit", default: "1人前", null: false
    t.float "calorie", default: 0.0, null: false
    t.float "protein", default: 0.0, null: false
    t.float "lipid", default: 0.0, null: false
    t.float "carbohydrate", default: 0.0, null: false
    t.float "dietary_fiber", default: 0.0, null: false
    t.float "salt", default: 0.0, null: false
  end

  create_table "refund_supports", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "occurred_at", null: false
    t.integer "store_id", null: false
    t.integer "status", default: 0, null: false
    t.string "staff_name"
    t.text "content"
    t.date "visit_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reminder_template_stores", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "reminder_template_id", null: false
    t.integer "store_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reminder_templates", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "repeat_type", null: false
    t.time "action_time"
    t.string "content", null: false
    t.text "memo"
    t.integer "status", default: 0, null: false
    t.string "drafter", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "category", default: 0, null: false
    t.boolean "important_flag", default: false, null: false
    t.string "image"
  end

  create_table "reminders", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "store_id", null: false
    t.integer "reminder_template_id"
    t.date "action_date", null: false
    t.time "action_time"
    t.string "content", default: "", null: false
    t.text "memo"
    t.integer "status", default: 0, null: false
    t.datetime "status_change_datetime"
    t.string "drafter", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "important_flag", default: false, null: false
    t.integer "category", default: 0, null: false
    t.integer "do_staff"
    t.integer "check_staff"
    t.integer "important_status"
  end

  create_table "sales_report_staffs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "sales_report_id", null: false
    t.bigint "staff_id", null: false
    t.integer "smile"
    t.integer "eyecontact"
    t.integer "voice_volume"
    t.integer "talk_speed"
    t.integer "speed"
    t.integer "total"
    t.text "memo"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "tasting"
    t.index ["sales_report_id"], name: "index_sales_report_staffs_on_sales_report_id"
    t.index ["staff_id"], name: "index_sales_report_staffs_on_staff_id"
  end

  create_table "sales_reports", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "analysis_id", null: false
    t.integer "store_id", null: false
    t.date "date", null: false
    t.integer "staff_id", null: false
    t.text "good"
    t.text "issue"
    t.text "other_memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cash_error"
    t.text "excess_or_deficiency_number_memo"
    t.time "leaving_work"
    t.integer "vegetable_waste_amount", default: 0, null: false
    t.float "one_pair_one_talk"
    t.integer "tasting_number"
    t.integer "tasting_atack"
  end

  create_table "serving_plates", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "image"
    t.integer "color"
    t.integer "shape"
    t.integer "genre"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shift_frames", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "group_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shift_patterns", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "pattern_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "group_id"
  end

  create_table "shifts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "date"
    t.integer "store_id"
    t.bigint "staff_id", null: false
    t.integer "shift_pattern_id"
    t.integer "fix_shift_pattern_id"
    t.text "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "fixed_flag", default: false, null: false
    t.time "start_time"
    t.time "end_time"
    t.time "rest_start_time"
    t.time "rest_end_time"
    t.index ["date", "staff_id"], name: "index_shifts_on_date_and_staff_id", unique: true
    t.index ["date"], name: "index_shifts_on_date"
    t.index ["staff_id"], name: "index_shifts_on_staff_id"
  end

  create_table "smaregi_member_products", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "kaiin_id"
    t.integer "product_id"
    t.integer "early_number_of_purchase"
    t.integer "total_number_of_purchase"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "smaregi_members", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "kaiin_id", null: false
    t.string "kaiin_code", null: false
    t.string "sei_kana", null: false
    t.string "mei_kana", null: false
    t.string "mobile", null: false
    t.integer "sex", default: 0, null: false
    t.date "birthday"
    t.integer "point"
    t.date "point_limit"
    t.datetime "last_visit_store"
    t.date "nyukaibi"
    t.date "taikaibi"
    t.text "memo"
    t.integer "kaiin_zyotai", default: 0, null: false
    t.integer "main_use_store", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "raiten_kaisu", default: 0, null: false
  end

  create_table "smaregi_trading_histories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.date "date"
    t.integer "analysis_id"
    t.integer "torihiki_id"
    t.datetime "torihiki_nichiji"
    t.integer "tanka_nebikimae_shokei"
    t.integer "tanka_nebiki_shokei"
    t.integer "shokei"
    t.integer "shokei_nebiki"
    t.float "shokei_waribikiritsu"
    t.integer "point_nebiki"
    t.integer "gokei"
    t.integer "suryo_gokei"
    t.integer "henpinsuryo_gokei"
    t.integer "huyo_point"
    t.integer "shiyo_point"
    t.integer "genzai_point"
    t.integer "gokei_point"
    t.integer "tenpo_id"
    t.integer "kaiin_id"
    t.string "kaiin_code"
    t.integer "tanmatsu_torihiki_id"
    t.integer "nenreiso"
    t.integer "kyakuso_id"
    t.integer "hanbaiin_id"
    t.string "hanbaiin_mei"
    t.integer "torihikimeisai_id"
    t.integer "torihiki_meisaikubun"
    t.integer "shohin_id"
    t.string "shohin_code"
    t.integer "hinban"
    t.string "shohinmei"
    t.integer "shohintanka"
    t.integer "hanbai_tanka"
    t.integer "tanpin_nebiki"
    t.integer "tanpin_waribiki"
    t.integer "suryo"
    t.integer "nebikimaekei"
    t.integer "tanka_nebikikei"
    t.integer "nebikigokei"
    t.integer "bumon_id"
    t.string "bumonmei"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.time "time"
    t.integer "uchikeshi_torihiki_id"
    t.integer "uchikeshi_kubun"
    t.bigint "receipt_number"
    t.integer "shiharaihouhou"
    t.integer "uchishohizei"
    t.integer "uchizeianbun"
    t.integer "zeinuki_uriage"
    t.string "shokei_nebiki_kubun"
    t.string "tanpin_nebiki_kubun"
    t.integer "shokei_nebiki_anbun"
    t.integer "point_nebiki_anbun"
    t.integer "sotozei_anbun"
    t.integer "shain_nebiki_anbun"
    t.integer "sale_nebiki_anbun"
    t.index ["analysis_id"], name: "index_smaregi_trading_histories_on_analysis_id"
    t.index ["date"], name: "index_smaregi_trading_histories_on_date"
    t.index ["kaiin_id"], name: "index_smaregi_trading_histories_on_kaiin_id"
  end

  create_table "staff_stores", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "staff_id"
    t.integer "store_id"
    t.integer "transportation_expenses"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["staff_id", "store_id"], name: "index_staff_stores_on_staff_id_and_store_id", unique: true
  end

  create_table "staffs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.text "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "employment_status", default: 0, null: false
    t.integer "row", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.integer "staff_code"
    t.integer "smaregi_hanbaiin_id"
    t.string "phone_number"
    t.integer "group_id", null: false
    t.string "short_name", null: false
  end

  create_table "stocks", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "material_id"
    t.date "date", null: false
    t.float "start_day_stock", default: 0.0, null: false
    t.float "end_day_stock", default: 0.0, null: false
    t.float "used_amount", default: 0.0, null: false
    t.float "delivery_amount", default: 0.0, null: false
    t.boolean "inventory_flag", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "store_id"
    t.index ["date", "material_id", "store_id"], name: "index_stocks_on_date_and_material_id_and_store_id", unique: true
    t.index ["date"], name: "index_stocks_on_date"
    t.index ["material_id"], name: "index_stocks_on_material_id"
    t.index ["store_id"], name: "index_stocks_on_store_id"
  end

  create_table "store_daily_menu_detail_histories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "store_daily_menu_detail_id"
    t.integer "number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "store_daily_menu_details", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "store_daily_menu_id"
    t.bigint "product_id"
    t.integer "number", default: 0, null: false
    t.float "price", default: 0.0, null: false
    t.integer "total_price", default: 0, null: false
    t.integer "row_order", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "carry_over", default: 0, null: false
    t.integer "actual_inventory", default: 0, null: false
    t.boolean "sold_out_flag", default: false, null: false
    t.integer "serving_plate_id"
    t.boolean "signboard_flag", default: false, null: false
    t.boolean "pricecard_need_flag", default: false, null: false
    t.integer "stock_deficiency_excess", default: 0, null: false
    t.integer "sozai_number", default: 0, null: false
    t.integer "bento_fukusai_number", default: 0, null: false
    t.integer "showcase_type"
    t.integer "prepared_number", default: 0
    t.integer "excess_or_deficiency_number", default: 0
    t.index ["product_id"], name: "index_store_daily_menu_details_on_product_id"
    t.index ["store_daily_menu_id", "product_id"], name: "index_uniq", unique: true
    t.index ["store_daily_menu_id"], name: "index_store_daily_menu_details_on_store_daily_menu_id"
  end

  create_table "store_daily_menu_photos", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "store_daily_menu_id", null: false
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "store_daily_menus", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "daily_menu_id", null: false
    t.integer "store_id", null: false
    t.date "start_time", null: false
    t.integer "total_num", default: 0, null: false
    t.integer "weather"
    t.integer "max_temperature"
    t.integer "min_temperature"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "opentime_showcase_photo"
    t.string "showcase_photo_a"
    t.string "showcase_photo_b"
    t.string "signboard_photo"
    t.time "opentime_showcase_photo_uploaded"
    t.string "event"
    t.boolean "editable_flag", default: true, null: false
    t.integer "foods_budget", default: 0, null: false
    t.integer "goods_budget", default: 0, null: false
    t.integer "revised_foods_budget", default: 0, null: false
    t.integer "revised_goods_budget", default: 0, null: false
    t.index ["daily_menu_id", "store_id", "start_time"], name: "index_uniq", unique: true
  end

  create_table "store_shift_frames", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "store_id", null: false
    t.integer "shift_frame_id", null: false
    t.integer "default_number", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "default_working_hour", default: 0, null: false
    t.index ["store_id", "shift_frame_id"], name: "index_store_shift_frames_on_store_id_and_shift_frame_id", unique: true
  end

  create_table "stores", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name", null: false
    t.string "phone"
    t.string "fax"
    t.string "email"
    t.string "zip"
    t.text "address"
    t.string "staff_name"
    t.string "staff_phone"
    t.string "staff_email"
    t.text "memo"
    t.boolean "jfd", default: false, null: false
    t.integer "user_id"
    t.integer "smaregi_store_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lunch_default_shift"
    t.integer "dinner_default_shift"
    t.string "orikane_store_code"
    t.string "short_name"
    t.string "np_store_code"
    t.integer "group_id"
    t.string "task_slack_url"
    t.integer "store_type", default: 0, null: false
    t.boolean "close_flag", default: false, null: false
    t.string "yoyaku_url"
    t.string "line_url"
  end

  create_table "task_comments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "task_id", null: false
    t.text "content"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "image"
  end

  create_table "task_images", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "task_id", null: false
    t.string "image"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "task_staffs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "task_id", null: false
    t.integer "staff_id", null: false
    t.boolean "read_flag", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "task_stores", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "task_id"
    t.integer "store_id"
    t.boolean "subject_flag", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "tasks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.integer "status"
    t.string "drafter"
    t.text "final_decision"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "row_order"
    t.integer "category"
    t.integer "group_id", null: false
    t.boolean "part_staffs_share_flag", default: false, null: false
  end

  create_table "tastings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "product_id"
    t.integer "staff_id"
    t.date "date"
    t.text "comment"
    t.integer "appearance"
    t.integer "taste"
    t.integer "total_evaluation"
    t.integer "price_satisfaction"
    t.integer "sell_price"
    t.string "image"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "temporary_menu_materials", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "menu_material_id", null: false
    t.integer "material_id", null: false
    t.date "date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "origin_material_id"
    t.string "memo", collation: "utf8_general_ci"
    t.index ["date", "menu_material_id"], name: "index_temporary_menu_materials_on_date_and_menu_material_id", unique: true
  end

  create_table "to_store_message_stores", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "to_store_message_id", null: false
    t.integer "store_id"
    t.boolean "subject_flag", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "to_store_messages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.date "date"
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "last_mail_check"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false, null: false
    t.integer "group_id"
    t.boolean "vendor_flag", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vendors", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "company_name"
    t.string "company_phone"
    t.string "company_fax"
    t.string "company_mail"
    t.string "zip"
    t.text "address"
    t.string "staff_name"
    t.string "staff_phone"
    t.string "staff_mail"
    t.string "management_id"
    t.text "memo"
    t.string "delivery_date"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "fax_staff_name_display_flag", default: false, null: false
    t.integer "group_id", null: false
    t.string "name"
    t.string "delivery_able_wday", default: "0,1,2,3,4,5,6", null: false
    t.integer "user_id"
  end

  create_table "work_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.bigint "group_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "row_order"
    t.string "bg_color_code", default: "#4169e1", null: false
    t.boolean "rest_flag", default: false, null: false
    t.integer "category"
    t.index ["group_id"], name: "index_work_types_on_group_id"
  end

  create_table "working_hour_work_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "working_hour_id", null: false
    t.bigint "work_type_id", null: false
    t.datetime "start", null: false
    t.datetime "end", null: false
    t.float "worktime", default: 0.0, null: false
    t.text "memo"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "js_event_id"
    t.index ["work_type_id"], name: "index_working_hour_work_types_on_work_type_id"
    t.index ["working_hour_id"], name: "index_working_hour_work_types_on_working_hour_id"
  end

  create_table "working_hours", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "store_id"
    t.bigint "staff_id"
    t.date "date"
    t.float "working_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["staff_id"], name: "index_working_hours_on_staff_id"
    t.index ["store_id", "staff_id", "date"], name: "index_working_hours_on_store_id_and_staff_id_and_date", unique: true
    t.index ["store_id"], name: "index_working_hours_on_store_id"
  end

end
