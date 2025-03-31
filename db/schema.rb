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

ActiveRecord::Schema[7.2].define(version: 2025_03_30_224456) do
  create_table "business_types", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
  end

  create_table "businesses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "city"
    t.float "rating"
    t.string "zip_code"
    t.string "phone_number"
    t.float "latitude"
    t.float "longitude"
    t.integer "business_type"
    t.string "address"
    t.integer "communication_form"
    t.integer "mile_preference"
    t.string "contact_url"
    t.string "state"
    t.string "full_address"
    t.string "password_digest"
    t.boolean "admin", default: false
    t.boolean "is_stationary", default: false
  end

  create_table "events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "event_type"
    t.integer "business_id"
  end
end
