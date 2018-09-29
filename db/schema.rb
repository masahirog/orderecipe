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

ActiveRecord::Schema.define(version: 20180928135804) do

  create_table "food_additives", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "food_ingredients", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "food_group"
    t.integer  "food_number"
    t.integer  "index_number"
    t.string   "name"
    t.string   "complement"
    t.float    "calorie",       limit: 24
    t.float    "protein",       limit: 24
    t.float    "lipid",         limit: 24
    t.float    "carbohydrate",  limit: 24
    t.float    "dietary_fiber", limit: 24
    t.float    "potassium",     limit: 24
    t.float    "calcium",       limit: 24
    t.float    "vitamin_b1",    limit: 24
    t.float    "vitamin_b2",    limit: 24
    t.float    "vitamin_c",     limit: 24
    t.float    "salt",          limit: 24
    t.text     "memo",          limit: 65535
    t.datetime "created_at",                  default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at",                  default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "material_food_additives", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "material_id"
    t.integer  "food_additive_id"
    t.datetime "created_at",       default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at",       default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "materials", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "order_name"
    t.text     "calculated_value",    limit: 65535
    t.string   "calculated_unit"
    t.float    "calculated_price",    limit: 24
    t.float    "cost_price",          limit: 24
    t.string   "category"
    t.string   "order_code"
    t.text     "memo",                limit: 65535
    t.integer  "end_of_sales"
    t.integer  "vendor_id"
    t.datetime "created_at",                        default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at",                        default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string   "order_unit"
    t.text     "order_unit_quantity", limit: 65535
    t.text     "allergy",             limit: 65535
    t.integer  "stock_management"
  end

  create_table "menu_materials", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "menu_id"
    t.integer  "material_id"
    t.float    "amount_used",        limit: 24
    t.datetime "created_at",                    default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at",                    default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string   "preparation"
    t.string   "post"
    t.integer  "row_order"
    t.float    "gram_quantity",      limit: 24
    t.integer  "food_ingredient_id"
    t.float    "calorie",            limit: 24
    t.float    "protein",            limit: 24
    t.float    "lipid",              limit: 24
    t.float    "carbohydrate",       limit: 24
    t.float    "dietary_fiber",      limit: 24
    t.float    "potassium",          limit: 24
    t.float    "calcium",            limit: 24
    t.float    "vitamin_b1",         limit: 24
    t.float    "vitamin_b2",         limit: 24
    t.float    "vitamin_c",          limit: 24
    t.float    "salt",               limit: 24
  end

  create_table "menus", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.text     "recipe",          limit: 65535
    t.string   "category"
    t.text     "serving_memo",    limit: 65535
    t.float    "cost_price",      limit: 24
    t.datetime "created_at",                    default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at",                    default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string   "food_label_name"
    t.string   "used_additives",                default: ""
  end

  create_table "order_materials", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "order_id"
    t.integer  "material_id"
    t.text     "order_quantity",      limit: 65535
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.float    "calculated_quantity", limit: 24
    t.string   "order_material_memo"
    t.string   "delivery_date"
  end

  create_table "order_products", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "order_id"
    t.integer  "product_id"
    t.integer  "serving_for"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "make_date"
  end

  create_table "orders", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_menus", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "product_id"
    t.integer  "menu_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.integer  "row_order"
  end

  create_table "products", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "cook_category"
    t.string   "product_type"
    t.integer  "sell_price"
    t.text     "description",   limit: 65535
    t.text     "contents",      limit: 65535
    t.float    "cost_price",    limit: 24
    t.datetime "created_at",                  default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at",                  default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string   "product_image"
    t.integer  "bento_id"
  end

  create_table "stock_materials", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "stock_id"
    t.integer  "material_id"
    t.float    "amount",      limit: 24
    t.text     "memo",        limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "stocks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "vendors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "company_name"
    t.string   "company_phone"
    t.string   "company_fax"
    t.string   "company_mail"
    t.string   "zip"
    t.text     "address",       limit: 65535
    t.string   "staff_name"
    t.string   "staff_phone"
    t.string   "staff_mail"
    t.text     "memo",          limit: 65535
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "version_associations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "version_id"
    t.string  "foreign_key_name", null: false
    t.integer "foreign_key_id"
    t.index ["foreign_key_name", "foreign_key_id"], name: "index_version_associations_on_foreign_key", using: :btree
    t.index ["version_id"], name: "index_version_associations_on_version_id", using: :btree
  end

  create_table "versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string   "item_type",      limit: 191,        null: false
    t.integer  "item_id",                           null: false
    t.string   "event",                             null: false
    t.string   "whodunnit"
    t.text     "object",         limit: 4294967295
    t.datetime "created_at"
    t.integer  "transaction_id"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
    t.index ["transaction_id"], name: "index_versions_on_transaction_id", using: :btree
  end

end
