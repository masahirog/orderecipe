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

ActiveRecord::Schema.define(version: 2022_04_20_085131) do

  create_table "analyses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "store_id"
    t.date "date"
    t.integer "sales_amount"
    t.integer "loss_amount"
    t.integer "labor_cost"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "transaction_count", default: 0, null: false
    t.integer "fourteen_transaction_count", default: 0, null: false
    t.integer "fourteen_number_sales_sozai", default: 0, null: false
    t.integer "total_number_sales_sozai", default: 0, null: false
    t.index ["date", "store_id"], name: "index_analyses_on_date_and_store_id", unique: true
  end

  create_table "analysis_products", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "analysis_id"
    t.integer "smaregi_shohin_id"
    t.string "smaregi_shohin_name"
    t.integer "smaregi_shohintanka"
    t.integer "product_id"
    t.integer "orderecipe_sell_price"
    t.float "cost_price"
    t.integer "list_price"
    t.integer "manufacturing_number"
    t.integer "carry_over"
    t.integer "actual_inventory"
    t.integer "sales_number"
    t.integer "loss_number"
    t.integer "total_sales_amount"
    t.integer "loss_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "early_sales_number", default: 0, null: false
    t.boolean "exclusion_flag", default: false, null: false
    t.float "potential"
  end

  create_table "brands", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.integer "store_id", default: 0, null: false
    t.boolean "kurumesi_flag", default: false, null: false
    t.string "store_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "containers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
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

  create_table "daily_menu_details", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "daily_menu_id", null: false
    t.integer "product_id", null: false
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
  end

  create_table "daily_menus", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.date "start_time", null: false
    t.integer "total_manufacturing_number", default: 0, null: false
    t.integer "weather"
    t.integer "max_temperature"
    t.integer "min_temperature"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sozai_manufacturing_number", default: 0, null: false
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

  create_table "fix_shift_pattern_shift_frames", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "fix_shift_pattern_id"
    t.integer "shift_frame_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fix_shift_patterns", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "pattern_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "working_hour"
    t.time "start_time"
    t.time "end_time"
    t.integer "group_id"
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

  create_table "groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "kaizen_lists", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "product_id"
    t.string "author"
    t.string "kaizen_staff"
    t.text "kaizen_point"
    t.integer "priority", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.text "kaizen_result"
    t.boolean "or_change_flag", default: false, null: false
    t.boolean "share_flag", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "before_image"
    t.string "after_image"
    t.integer "store_id", null: false
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

  create_table "material_cut_patterns", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "material_id", null: false
    t.string "name"
    t.integer "machine"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "material_food_additives", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "material_id", null: false
    t.integer "food_additive_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "material_store_orderables", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
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
    t.index ["material_id", "store_id"], name: "index_material_store_orderables_on_material_id_and_store_id", unique: true
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
    t.date "last_inventory_date"
    t.boolean "need_inventory_flag", default: false, null: false
    t.string "image"
    t.string "short_name"
    t.integer "storage_place", default: 0, null: false
    t.boolean "subdivision_able", default: false, null: false
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
    t.boolean "source_flag", default: false, null: false
    t.integer "source_group"
    t.boolean "first_flag", default: false, null: false
    t.boolean "machine_flag", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "material_cut_pattern_id"
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
    t.integer "daybefore_20_cut", default: 0, null: false
    t.integer "daybefore_60_cut", default: 0, null: false
    t.integer "daybefore_20_cook", default: 0, null: false
    t.integer "daybefore_60_cook", default: 0, null: false
    t.integer "onday_20_cook", default: 0, null: false
    t.integer "onday_60_cook", default: 0, null: false
    t.string "short_name"
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
    t.integer "store_id", null: false
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
    t.string "staff_name"
    t.integer "store_id"
  end

  create_table "place_showcases", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "product_parts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "product_id", null: false
    t.string "name", default: "", null: false
    t.float "amount", default: 0.0, null: false
    t.string "unit", null: false
    t.string "memo"
    t.integer "container", default: 0, null: false
    t.boolean "sticker_print_flag", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_pops", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "product_id", null: false
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.integer "sell_price"
    t.text "description"
    t.text "contents"
    t.float "cost_price"
    t.string "image"
    t.integer "management_id"
    t.string "short_name"
    t.string "symbol"
    t.integer "status", default: 1, null: false
    t.integer "brand_id"
    t.integer "product_category", default: 1, null: false
    t.integer "cooking_rice_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "bejihan_sozai_flag", default: false, null: false
    t.string "display_image"
    t.string "image_for_one_person"
    t.text "serving_infomation"
    t.string "food_label_name"
    t.text "food_label_content"
    t.boolean "carryover_able_flag", default: false, null: false
    t.integer "main_serving_plate_id"
    t.integer "sub_serving_plate_id"
    t.integer "container_id"
    t.boolean "freezing_able_flag", default: false, null: false
  end

  create_table "sales_reports", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "analysis_id", null: false
    t.integer "store_id", null: false
    t.date "date", null: false
    t.integer "staff_id", null: false
    t.integer "sales_amount"
    t.integer "sales_count"
    t.text "good"
    t.text "issue"
    t.text "other_memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cash_error"
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

  create_table "shifts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.date "date"
    t.integer "store_id"
    t.integer "staff_id"
    t.integer "shift_pattern_id"
    t.integer "fix_shift_pattern_id"
    t.text "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.integer "shikei_nebiki"
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
  end

  create_table "staffs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "store_id", null: false
    t.string "name", null: false
    t.text "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "employment_status", default: 0, null: false
    t.integer "row", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.integer "jobcan_staff_code"
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
    t.integer "store_id", null: false
    t.index ["date", "material_id", "store_id"], name: "index_stocks_on_date_and_material_id_and_store_id", unique: true
  end

  create_table "store_daily_menu_details", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "store_daily_menu_id", null: false
    t.integer "product_id", null: false
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
    t.boolean "window_pop_flag", default: false, null: false
    t.integer "stock_deficiency_excess", default: 0, null: false
    t.integer "sozai_number", default: 0, null: false
    t.integer "bento_fukusai_number", default: 0, null: false
  end

  create_table "store_daily_menu_photos", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "store_daily_menu_id", null: false
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "store_daily_menus", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "daily_menu_id"
    t.integer "store_id"
    t.date "start_time"
    t.integer "total_num", default: 0, null: false
    t.integer "weather"
    t.integer "max_temperature"
    t.integer "min_temperature"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "store_shift_frames", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "store_id", null: false
    t.integer "shift_frame_id", null: false
    t.integer "default_number", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "default_working_hour", default: 0, null: false
  end

  create_table "stores", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
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
  end

  create_table "task_template_stores", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "task_template_id", null: false
    t.integer "store_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_template_id", "store_id"], name: "index_task_template_stores_on_task_template_id_and_store_id", unique: true
  end

  create_table "task_templates", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "repeat_type", null: false
    t.time "action_time"
    t.string "content", null: false
    t.text "memo"
    t.integer "status", default: 0, null: false
    t.string "drafter", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tasks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "store_id", null: false
    t.integer "task_template_id"
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
    t.string "delivery_date"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
