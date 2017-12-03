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

ActiveRecord::Schema.define(version: 20171203062908) do

  create_table "gateway_customers", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "gateway", null: false
    t.string "customer_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gateway", "customer_id"], name: "index_gateway_customers_on_gateway_and_customer_id", unique: true
    t.index ["user_id", "gateway", "deleted_at"], name: "index_gateway_customers_on_user_id_and_gateway_and_deleted_at"
  end

  create_table "membership_levels", force: :cascade do |t|
    t.string "name", null: false
    t.integer "usd_cost", null: false
    t.integer "num_free_guests", default: 0, null: false
    t.integer "additional_guest_usd_cost", default: 1999, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "subscription_plan_id", null: false
    t.index ["name"], name: "index_membership_levels_on_name", unique: true
    t.index ["subscription_plan_id"], name: "index_membership_levels_on_subscription_plan_id", unique: true
  end

  create_table "memberships", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "membership_level_id", null: false
    t.integer "num_guests", null: false
    t.datetime "canceled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "gateway", null: false
    t.string "subscription_id", null: false
    t.index ["gateway", "subscription_id"], name: "index_memberships_on_gateway_and_subscription_id", unique: true
    t.index ["user_id", "membership_level_id", "canceled_at"], name: "index_memberships_on_ids_and_canceled_at"
  end

  create_table "users", force: :cascade do |t|
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

end
