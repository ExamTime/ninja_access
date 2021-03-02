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

ActiveRecord::Schema.define(version: 2014_08_03_142052) do

  create_table "ninja_access_groups", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ninja_access_groups_permissions", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "group_id"
    t.integer "permission_id"
    t.index ["group_id", "permission_id"], name: "index_na_groups_permissions_on_group_id_and_permission_id", unique: true
    t.index ["permission_id"], name: "fk_rails_f1d88100a5"
  end

  create_table "ninja_access_groups_users", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.index ["group_id", "user_id"], name: "index_na_groups_users_on_group_id_and_user_id", unique: true
    t.index ["user_id"], name: "fk_rails_fcbc2b3794"
  end

  create_table "ninja_access_permissions", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "action", null: false
    t.string "accessible_type"
    t.integer "accessible_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["accessible_id", "accessible_type", "action"], name: "index_na_permissions_on_accessible_and_action", unique: true
  end

  create_table "resource_as", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resource_bs", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resource_cs", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", id: :integer, charset: "utf8", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_foreign_key "ninja_access_groups_permissions", "ninja_access_groups", column: "group_id"
  add_foreign_key "ninja_access_groups_permissions", "ninja_access_permissions", column: "permission_id"
  add_foreign_key "ninja_access_groups_users", "ninja_access_groups", column: "group_id"
  add_foreign_key "ninja_access_groups_users", "users"
end
