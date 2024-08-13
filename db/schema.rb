# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_08_05_061807) do
  create_table "app_banners", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "image_url"
    t.string "action_url"
    t.boolean "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "app_opens", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "version_name"
    t.string "version_code"
    t.string "source_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_app_opens_on_user_id"
  end

  create_table "bid_offers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "offer_name"
    t.string "offer_price"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.text "offer_image_url"
    t.string "offer_video_url"
    t.text "offer_desc"
    t.boolean "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bid_plan_categories", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "status", default: true
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bid_plans", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "number_of_bids"
    t.string "expires_in"
    t.string "off_percentage"
    t.string "plan_price"
    t.bigint "bid_plan_category_id"
    t.boolean "status", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bid_plan_category_id"], name: "index_bid_plans_on_bid_plan_category_id"
  end

  create_table "closed_bids", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "bid_offer_id", null: false
    t.string "lowest_bid"
    t.string "winner1_city", default: "New Delhi"
    t.string "winner2_city", default: "New Delhi"
    t.string "winner3_city", default: "New Delhi"
    t.string "winner1_state", default: "Delhi"
    t.string "winner2_state", default: "Delhi"
    t.string "winner3_state", default: "Delhi"
    t.json "winners"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bid_offer_id"], name: "index_closed_bids_on_bid_offer_id"
  end

  create_table "transaction_histories", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "payment_id"
    t.string "title"
    t.string "receipt"
    t.string "order_id"
    t.string "amount"
    t.string "number_of_bids"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_transaction_histories_on_user_id"
  end

  create_table "user_bids", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "bid_offer_id", null: false
    t.json "bids"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bid_offer_id"], name: "index_user_bids_on_bid_offer_id"
    t.index ["user_id"], name: "index_user_bids_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "device_id"
    t.string "device_type"
    t.string "device_name"
    t.string "advertising_id"
    t.string "social_name"
    t.string "social_type"
    t.string "social_id"
    t.string "social_email"
    t.string "social_img_url"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_content"
    t.string "utm_term"
    t.string "version_name"
    t.string "version_code"
    t.string "source_ip"
    t.string "utm_campaign"
    t.string "referrer_url"
    t.string "security_token"
    t.string "refer_code"
    t.string "total_bids"
    t.string "mobile_number"
    t.string "address"
    t.datetime "last_check_in"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "app_opens", "users"
  add_foreign_key "closed_bids", "bid_offers"
  add_foreign_key "transaction_histories", "users"
  add_foreign_key "user_bids", "bid_offers"
  add_foreign_key "user_bids", "users"
end
