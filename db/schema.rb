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

ActiveRecord::Schema.define(version: 20151217091603) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "faces", force: :cascade do |t|
    t.integer  "photo_id"
    t.integer  "label_id"
    t.binary   "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "faces", ["label_id"], name: "index_faces_on_label_id", using: :btree
  add_index "faces", ["photo_id"], name: "index_faces_on_photo_id", using: :btree

  create_table "labels", force: :cascade do |t|
    t.string   "name"
    t.text     "tags"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "photos", force: :cascade do |t|
    t.text     "source_url"
    t.text     "photo_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text     "caption"
    t.datetime "posted_at"
    t.string   "uid"
  end

  add_index "photos", ["uid"], name: "index_photos_on_uid", unique: true, using: :btree

  create_table "queries", force: :cascade do |t|
    t.text     "text"
    t.datetime "executed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "faces", "labels"
  add_foreign_key "faces", "photos"
end
