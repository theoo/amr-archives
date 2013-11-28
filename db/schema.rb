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

ActiveRecord::Schema.define(version: 20130919075939) do

  create_table "artists", force: true do |t|
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bands", force: true do |t|
    t.string   "name"
    t.text     "desc"
    t.integer  "genre_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", force: true do |t|
    t.string   "name"
    t.text     "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "genres", force: true do |t|
    t.string   "name"
    t.text     "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "instruments", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", force: true do |t|
    t.string   "name"
    t.text     "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "medias", force: true do |t|
    t.integer  "performance_id"
    t.string   "name"
    t.string   "mime"
    t.text     "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
  end

  create_table "performances", force: true do |t|
    t.integer  "event_id"
    t.integer  "location_id"
    t.integer  "band_id"
    t.datetime "date"
    t.text     "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "stage"
    t.string   "price"
    t.string   "ticketing"
    t.datetime "doors_opening"
  end

  add_index "performances", ["band_id"], name: "index_performances_on_band_id", using: :btree
  add_index "performances", ["event_id"], name: "index_performances_on_event_id", using: :btree
  add_index "performances", ["location_id"], name: "index_performances_on_location_id", using: :btree

  create_table "performers", force: true do |t|
    t.integer  "artist_id"
    t.integer  "instrument_id"
    t.integer  "performance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "performers", ["artist_id"], name: "index_performers_on_artist_id", using: :btree
  add_index "performers", ["instrument_id"], name: "index_performers_on_instrument_id", using: :btree
  add_index "performers", ["performance_id"], name: "index_performers_on_performance_id", using: :btree

  create_table "users", force: true do |t|
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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
