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

ActiveRecord::Schema.define(version: 2020_03_28_092428) do

  create_table "brands", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.integer "store_id", null: false
    t.boolean "kurumesi_flag", null: false
    t.string "store_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cooking_rice_materials", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "cooking_rice_id", null: false
    t.integer "material_id", null: false
    t.float "used_amount", default: 0.0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cooking_rices", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.integer "base_rice", null: false
    t.integer "serving_amount", null: false
    t.float "shoku_per_shou", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

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

  create_table "date_manufacture_numbers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.date "date"
    t.integer "num"
    t.boolean "notified_flag", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.float "magnesium"
    t.float "iron"
    t.float "zinc"
    t.float "copper"
    t.float "folic_acid"
    t.float "vitamin_d"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "kurumesi_admin_data", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "store_name"
    t.date "delivery_date"
    t.time "pick_time"
    t.string "delivery_time"
    t.string "delivery_address"
    t.text "products"
    t.string "order_price"
    t.string "total_price"
    t.string "delivery_company"
    t.string "delivery_name"
    t.string "payment"
    t.datetime "order_date"
    t.string "status"
    t.integer "order_id"
    t.integer "member_id"
    t.string "orderer_name"
    t.string "orderer_company"
    t.string "orderer_mail"
    t.string "orderer_tell"
    t.string "ordered_site"
    t.string "ordered_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "kurumesi_mails", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "kurumesi_order_id"
    t.string "subject"
    t.text "body"
    t.integer "summary"
    t.datetime "recieved_datetime"
    t.boolean "kurumesi_order_reflect_flag", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "kurumesi_order_details", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "kurumesi_order_id", null: false
    t.integer "product_id", null: false
    t.integer "number", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "kurumesi_orders", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.date "start_time", null: false
    t.integer "management_id", null: false
    t.time "pick_time"
    t.integer "payment", default: 0, null: false
    t.boolean "canceled_flag", default: false, null: false
    t.integer "billed_amount", default: 0, null: false
    t.text "memo"
    t.integer "brand_id", null: false
    t.boolean "confirm_flag", default: false, null: false
    t.time "delivery_time"
    t.string "company_name"
    t.string "staff_name"
    t.string "delivery_address"
    t.string "reciept_name"
    t.string "proviso"
    t.integer "total_price", default: 0
    t.boolean "capture_done", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "kitchen_memo"
  end

  create_table "material_food_additives", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "material_id", null: false
    t.integer "food_additive_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.boolean "stock_management_flag", default: true, null: false
    t.date "last_inventory_date"
    t.boolean "need_inventory_flag", default: false, null: false
    t.string "image"
  end

  create_table "menu_materials", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "menu_id", null: false
    t.integer "material_id", null: false
    t.float "amount_used", default: 0.0, null: false
    t.string "preparation"
    t.string "post"
    t.integer "row_order", default: 0, null: false
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
    t.integer "base_menu_material_id"
    t.boolean "rice_mixed_flag", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "menus", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "roma_name"
    t.text "cook_the_day_before"
    t.integer "category"
    t.text "serving_memo"
    t.float "cost_price"
    t.string "food_label_name"
    t.string "used_additives", default: "", null: false
    t.boolean "confirm_flag", default: false, null: false
    t.text "cook_on_the_day"
    t.string "image"
    t.integer "base_menu_id"
    t.integer "serving_cost", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "monthly_stocks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.date "date"
    t.integer "item_number"
    t.integer "total_amount"
    t.integer "foods_amount"
    t.integer "equipments_amount"
    t.integer "expendables_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_materials", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "material_id", null: false
    t.string "order_quantity", default: "0", null: false
    t.float "calculated_quantity"
    t.string "order_material_memo"
    t.date "delivery_date"
    t.text "menu_name"
    t.boolean "un_order_flag", default: false, null: false
    t.boolean "fax_sended_flag", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
  end

  create_table "product_menus", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "menu_id", null: false
    t.integer "row_order", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.integer "sell_price"
    t.text "description"
    t.text "contents"
    t.float "cost_price"
    t.string "image"
    t.integer "management_id"
    t.text "memo"
    t.string "short_name"
    t.string "symbol"
    t.integer "status", default: 1, null: false
    t.integer "brand_id"
    t.integer "product_category", default: 1, null: false
    t.integer "cooking_rice_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reviews", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "brand_id"
    t.date "delivery_date"
    t.string "delivery_area"
    t.string "title"
    t.text "post"
    t.string "use_scene"
    t.string "age"
    t.string "score"
    t.boolean "line_sended", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.string "efax_address"
    t.text "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
