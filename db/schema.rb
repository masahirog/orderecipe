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

ActiveRecord::Schema.define(version: 20170730105856) do

  create_table "materials", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name"
    t.string   "delivery_slip_name"
    t.integer  "calculated_value"
    t.string   "calculated_unit"
    t.integer  "calculated_price"
    t.float    "cost_price",         limit: 24
    t.string   "cost_unit"
    t.string   "category"
    t.string   "vendor"
    t.integer  "code"
    t.text     "memo",               limit: 65535
    t.string   "status"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "menu_materials", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "menu_id"
    t.integer  "material_id"
    t.float    "amount_used", limit: 24
    t.float    "cost_price",  limit: 24
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "menus", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name"
    t.text     "recipe",       limit: 65535
    t.string   "category"
    t.text     "serving_memo", limit: 65535
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.float    "cost_price",   limit: 24
  end

  create_table "products", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name"
    t.string   "cook_category"
    t.string   "product_type"
    t.integer  "sell_price"
    t.text     "description",   limit: 65535
    t.text     "contents",      limit: 65535
    t.float    "cost_price",    limit: 24
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

end
