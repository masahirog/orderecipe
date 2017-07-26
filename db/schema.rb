# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20170722141441) do

  create_table "materials", force: :cascade do |t|
    t.string   "material_name",      limit: 255
    t.string   "delivery_slip_name", limit: 255
    t.integer  "calculated_value",   limit: 4
    t.string   "calculated_unit",    limit: 255
    t.integer  "calculated_price",   limit: 4
    t.float    "cost",               limit: 24
    t.string   "cost_unit",          limit: 255
    t.string   "category",           limit: 255
    t.string   "vendor",             limit: 255
    t.integer  "code",               limit: 4
    t.text     "memo",               limit: 65535
    t.string   "status",             limit: 255
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "menu_materials", force: :cascade do |t|
    t.integer  "menu_id",     limit: 4
    t.integer  "material_id", limit: 4
    t.float    "amount_used", limit: 24
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "menus", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.text     "recipe",       limit: 65535
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "category",     limit: 255
    t.text     "serving_memo", limit: 65535
  end

  create_table "products", force: :cascade do |t|
    t.string   "product_name",  limit: 255
    t.string   "cook_category", limit: 255
    t.string   "product_type",  limit: 255
    t.integer  "sell_price",    limit: 4
    t.text     "description",   limit: 65535
    t.text     "contents",      limit: 65535
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

end
