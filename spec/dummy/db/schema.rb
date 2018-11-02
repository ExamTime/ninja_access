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

ActiveRecord::Schema.define(version: 20140803142052) do

  create_table "ninja_access_groups", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ninja_access_groups_permissions", force: :cascade do |t|
    t.integer "group_id",      limit: 4
    t.integer "permission_id", limit: 4
  end

  add_index "ninja_access_groups_permissions", ["group_id", "permission_id"], name: "index_na_groups_permissions_on_group_id_and_permission_id", unique: true, using: :btree
  add_index "ninja_access_groups_permissions", ["permission_id"], name: "ninja_access_groups_permissions_permission_id_fk", using: :btree

  create_table "ninja_access_groups_users", force: :cascade do |t|
    t.integer "group_id", limit: 4
    t.integer "user_id",  limit: 4
  end

  add_index "ninja_access_groups_users", ["group_id", "user_id"], name: "index_na_groups_users_on_group_id_and_user_id", unique: true, using: :btree
  add_index "ninja_access_groups_users", ["user_id"], name: "ninja_access_groups_users_user_id_fk", using: :btree

  create_table "ninja_access_permissions", force: :cascade do |t|
    t.string   "action",          limit: 255, null: false
    t.integer  "accessible_id",   limit: 4
    t.string   "accessible_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ninja_access_permissions", ["accessible_id", "accessible_type", "action"], name: "index_na_permissions_on_accessible_and_action", unique: true, using: :btree

  create_table "resource_as", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resource_bs", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resource_cs", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_foreign_key "ninja_access_groups_permissions", "ninja_access_groups", column: "group_id", name: "ninja_access_groups_permissions_group_id_fk"
  add_foreign_key "ninja_access_groups_permissions", "ninja_access_permissions", column: "permission_id", name: "ninja_access_groups_permissions_permission_id_fk"
  add_foreign_key "ninja_access_groups_users", "ninja_access_groups", column: "group_id", name: "ninja_access_groups_users_group_id_fk"
  add_foreign_key "ninja_access_groups_users", "users", name: "ninja_access_groups_users_user_id_fk"
end
