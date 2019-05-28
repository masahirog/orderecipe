# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_05_20_073054) do

  create_table "daily_menu_details", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "daily_menu_id", null: false
    t.integer "product_id", null: false
    t.integer "manufacturing_number", default: 0, null: false
    t.float "cost_price_per_product", default: 0.0, null: false
    t.integer "total_cost_price", default: 0, null: false
    t.integer "row_order", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "daily_menus", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.date "start_time", null: false
    t.integer "total_manufacturing_number", default: 0, null: false
    t.boolean "fixed_flag", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "food_additives", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "food_ingredients", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "food_group"
    t.integer "food_number"
    t.integer "index_number"
    t.string "name"
    t.string "complement"
    t.float "calorie"
    t.float "protein"
    t.float "lipid"
    t.float "carbohydrate"
    t.float "dietary_fiber"
    t.float "potassium"
    t.float "calcium"
    t.float "vitamin_b1"
    t.float "vitamin_b2"
    t.float "vitamin_c"
    t.float "salt"
    t.text "memo"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.float "magnesium"
    t.float "iron"
    t.float "zinc"
    t.float "copper"
    t.float "folic_acid"
    t.float "vitamin_d"
  end

  create_table "masu_order_details", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "masu_order_id", null: false
    t.integer "product_id", null: false
    t.integer "number", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "masu_orders", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "number", default: 0, null: false
    t.date "start_time", null: false
    t.integer "kurumesi_order_id", null: false
    t.time "pick_time"
    t.boolean "fixed_flag", default: false, null: false
    t.integer "payment", default: 0, null: false
    t.integer "tea", default: 0, null: false
    t.integer "miso", default: 0, null: false
    t.integer "trash_bags", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "material_food_additives", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "material_id"
    t.integer "food_additive_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "materials", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "order_name"
    t.text "calculated_value"
    t.string "calculated_unit"
    t.float "calculated_price"
    t.float "cost_price"
    t.string "category"
    t.string "order_code"
    t.text "memo"
    t.integer "end_of_sales"
    t.integer "vendor_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "order_unit"
    t.text "order_unit_quantity"
    t.text "allergy"
    t.integer "vegetable_flag", default: 0, null: false
    t.boolean "vendor_stock_flag", default: true, null: false
    t.integer "delivery_deadline", default: 1, null: false
    t.integer "storage_location_id", null: false
  end

  create_table "menu_materials", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "menu_id"
    t.integer "material_id"
    t.float "amount_used"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "preparation"
    t.string "post"
    t.integer "row_order"
    t.float "gram_quantity"
    t.integer "food_ingredient_id"
    t.float "calorie"
    t.float "protein"
    t.float "lipid"
    t.float "carbohydrate"
    t.float "dietary_fiber"
    t.float "potassium"
    t.float "calcium"
    t.float "vitamin_b1"
    t.float "vitamin_b2"
    t.float "vitamin_c"
    t.float "salt"
    t.float "magnesium"
    t.float "iron"
    t.float "zinc"
    t.float "copper"
    t.float "folic_acid"
    t.float "vitamin_d"
  end

  create_table "menus", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.text "recipe"
    t.string "category"
    t.text "serving_memo"
    t.float "cost_price"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "food_label_name"
    t.string "used_additives", default: ""
    t.integer "confirm_flag", default: 0, null: false
    t.text "taste_description"
    t.string "image"
  end

  create_table "order_materials", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "order_id"
    t.integer "material_id"
    t.text "order_quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "calculated_quantity"
    t.string "order_material_memo"
    t.string "delivery_date"
    t.text "menu_name"
    t.string "calculated_unit"
    t.string "order_unit"
    t.boolean "un_order_flag", default: false, null: false
  end

  create_table "order_products", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "order_id"
    t.integer "product_id"
    t.integer "serving_for"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "make_date"
  end

  create_table "orders", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "fixed_flag", default: false, null: false
  end

  create_table "product_menus", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "product_id"
    t.integer "menu_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.integer "row_order"
  end

  create_table "products", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "cook_category"
    t.string "product_type"
    t.integer "sell_price"
    t.text "description"
    t.text "contents"
    t.float "cost_price"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "product_image"
    t.integer "bento_id"
    t.text "memo"
    t.string "short_name"
    t.text "masu_obi_url"
  end

  create_table "stocks", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "material_id", null: false
    t.date "date", null: false
    t.float "start_day_stock", default: 0.0, null: false
    t.float "end_day_stock", default: 0.0, null: false
    t.float "used_amount", default: 0.0, null: false
    t.float "delivery_amount", default: 0.0, null: false
    t.boolean "inventory_flag", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date", "material_id"], name: "index_stocks_on_date_and_material_id", unique: true
  end

  create_table "storage_locations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.text "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "version_associations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "version_id"
    t.string "foreign_key_name", null: false
    t.integer "foreign_key_id"
    t.index ["foreign_key_name", "foreign_key_id"], name: "index_version_associations_on_foreign_key"
    t.index ["version_id"], name: "index_version_associations_on_version_id"
  end

  create_table "versions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "item_type", limit: 191, null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object", limit: 4294967295
    t.datetime "created_at"
    t.integer "transaction_id"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["transaction_id"], name: "index_versions_on_transaction_id"
  end

end
