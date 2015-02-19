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

ActiveRecord::Schema.define(version: 20150214155532) do

  create_table "account_transactions", force: :cascade do |t|
    t.integer  "user_id",          limit: 4
    t.integer  "company_id",       limit: 4
    t.datetime "transaction_date"
    t.string   "transaction_type", limit: 255
    t.string   "method",           limit: 255
    t.string   "note",             limit: 255
    t.float    "amount",           limit: 24
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "account_transactions", ["company_id"], name: "index_account_transactions_on_company_id", using: :btree
  add_index "account_transactions", ["user_id"], name: "index_account_transactions_on_user_id", using: :btree

  create_table "cars", force: :cascade do |t|
    t.integer "user_id", limit: 4
    t.string  "model",   limit: 255
    t.string  "brand",   limit: 255
    t.string  "color",   limit: 255
    t.string  "number",  limit: 255
  end

  add_index "cars", ["user_id"], name: "index_cars_on_user_id", using: :btree

  create_table "chats", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "chats_users", id: false, force: :cascade do |t|
    t.integer "chat_id", limit: 4
    t.integer "user_id", limit: 4
  end

  add_index "chats_users", ["chat_id"], name: "index_chats_users_on_chat_id", using: :btree
  add_index "chats_users", ["user_id"], name: "index_chats_users_on_user_id", using: :btree

  create_table "companies", force: :cascade do |t|
    t.string   "name",                        limit: 255, default: "",    null: false
    t.float    "balance",                     limit: 24,  default: 0.0
    t.boolean  "pay_on_refuse",               limit: 1,   default: false
    t.float    "driver_bid",                  limit: 24,  default: 0.0
    t.boolean  "sms_on_looking_for_car",      limit: 1,   default: false
    t.boolean  "sms_on_order_taken",          limit: 1,   default: false
    t.boolean  "sms_on_wait_for_client",      limit: 1,   default: false
    t.string   "sms_on_looking_for_car_text", limit: 255
    t.string   "sms_on_order_taken_text",     limit: 255
    t.string   "sms_on_wait_for_client_text", limit: 255
    t.integer  "pre_order_time",              limit: 4,   default: 60
    t.integer  "pre_order_confirm_time",      limit: 4,   default: 30
    t.integer  "user_id",                     limit: 4
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
  end

  create_table "messages", force: :cascade do |t|
    t.integer "chat_id",      limit: 4
    t.integer "user_id",      limit: 4
    t.string  "message_type", limit: 255
    t.string  "text",         limit: 255
    t.string  "file",         limit: 255
    t.boolean "read",         limit: 1,   default: false
  end

  add_index "messages", ["chat_id"], name: "index_messages_on_chat_id", using: :btree
  add_index "messages", ["user_id"], name: "index_messages_on_user_id", using: :btree

  create_table "order_events", force: :cascade do |t|
    t.integer  "order_id",   limit: 4
    t.integer  "user_id",    limit: 4
    t.datetime "event_date"
    t.string   "event_type", limit: 255
    t.string   "content",    limit: 255
  end

  add_index "order_events", ["order_id"], name: "index_order_events_on_order_id", using: :btree

  create_table "order_route_points", force: :cascade do |t|
    t.integer  "order_id",   limit: 4
    t.datetime "point_date"
    t.float    "latitude",   limit: 24
    t.float    "longitude",  limit: 24
  end

  add_index "order_route_points", ["order_id"], name: "index_order_route_points_on_order_id", using: :btree

  create_table "order_stops", force: :cascade do |t|
    t.integer "order_id",  limit: 4
    t.integer "index",     limit: 4
    t.float   "latitude",  limit: 24
    t.float   "longitude", limit: 24
    t.string  "street",    limit: 255
    t.string  "home",      limit: 255
    t.string  "flat",      limit: 255
  end

  add_index "order_stops", ["order_id"], name: "index_order_stops_on_order_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "company_id",        limit: 4
    t.integer  "number",            limit: 4
    t.datetime "order_date"
    t.datetime "close_date"
    t.string   "cancel_reason",     limit: 255
    t.string   "status",            limit: 255,                 null: false
    t.string   "note",              limit: 255
    t.string   "phone_number",      limit: 255,                 null: false
    t.float    "price",             limit: 24,  default: 0.0
    t.boolean  "pre",               limit: 1,   default: false
    t.boolean  "confirmation_sent", limit: 1,   default: false
    t.boolean  "confirmed",         limit: 1,   default: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  add_index "orders", ["company_id"], name: "index_orders_on_company_id", using: :btree

  create_table "orders_users", id: false, force: :cascade do |t|
    t.integer "order_id", limit: 4
    t.integer "user_id",  limit: 4
  end

  add_index "orders_users", ["order_id"], name: "index_orders_users_on_order_id", using: :btree
  add_index "orders_users", ["user_id"], name: "index_orders_users_on_user_id", using: :btree

  create_table "user_devices", force: :cascade do |t|
    t.integer "user_id", limit: 4
    t.string  "token",   limit: 255
  end

  add_index "user_devices", ["user_id"], name: "index_user_devices_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "provider",               limit: 255,                null: false
    t.string   "uid",                    limit: 255,   default: "", null: false
    t.string   "encrypted_password",     limit: 255,   default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,     default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "name",                   limit: 255
    t.string   "nickname",               limit: 255
    t.string   "image",                  limit: 255
    t.string   "email",                  limit: 255
    t.string   "username",               limit: 255
    t.string   "phone_number",           limit: 255
    t.string   "authentication_code",    limit: 255
    t.text     "tokens",                 limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id",             limit: 4
    t.string   "role",                   limit: 255
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.float    "balance",                limit: 24
    t.string   "call_sign",              limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true, using: :btree

end
