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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121209195943) do

  create_table "ninja_access_groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "ninja_access_groups_permissions", :force => true do |t|
    t.integer "group_id"
    t.integer "permission_id"
  end

  add_index "ninja_access_groups_permissions", ["group_id"], :name => "ninja_access_groups_permissions_group_id_fk"
  add_index "ninja_access_groups_permissions", ["permission_id"], :name => "ninja_access_groups_permissions_permission_id_fk"

  create_table "ninja_access_groups_users", :force => true do |t|
    t.integer "group_id"
    t.integer "user_id"
  end

  add_index "ninja_access_groups_users", ["group_id"], :name => "ninja_access_groups_users_group_id_fk"
  add_index "ninja_access_groups_users", ["user_id"], :name => "ninja_access_groups_users_user_id_fk"

  create_table "ninja_access_permissions", :force => true do |t|
    t.string   "action",          :null => false
    t.integer  "accessible_id"
    t.string   "accessible_type"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "ninja_access_permissions", ["accessible_id", "accessible_type", "action"], :name => "index_ninja_access_permissions_on_accessible_and_action", :unique => true

  create_table "ninja_access_sub_groups", :force => true do |t|
    t.integer  "parent_id",  :null => false
    t.integer  "child_id",   :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "ninja_access_sub_groups", ["child_id"], :name => "ninja_access_sub_groups_child_id_fk"
  add_index "ninja_access_sub_groups", ["parent_id", "child_id"], :name => "index_ninja_access_sub_groups_on_parent_id_and_child_id", :unique => true

  create_table "ninja_access_users_permissions", :force => true do |t|
    t.integer "user_id"
    t.integer "permission_id"
  end

  add_index "ninja_access_users_permissions", ["permission_id"], :name => "ninja_access_users_permissions_permission_id_fk"
  add_index "ninja_access_users_permissions", ["user_id"], :name => "ninja_access_users_permissions_user_id_fk"

  create_table "resource_as", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "resource_bs", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "resource_cs", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_foreign_key "ninja_access_groups_permissions", "ninja_access_groups", :name => "ninja_access_groups_permissions_group_id_fk", :column => "group_id"
  add_foreign_key "ninja_access_groups_permissions", "ninja_access_permissions", :name => "ninja_access_groups_permissions_permission_id_fk", :column => "permission_id"

  add_foreign_key "ninja_access_groups_users", "ninja_access_groups", :name => "ninja_access_groups_users_group_id_fk", :column => "group_id"
  add_foreign_key "ninja_access_groups_users", "users", :name => "ninja_access_groups_users_user_id_fk"

  add_foreign_key "ninja_access_sub_groups", "ninja_access_groups", :name => "ninja_access_sub_groups_child_id_fk", :column => "child_id"
  add_foreign_key "ninja_access_sub_groups", "ninja_access_groups", :name => "ninja_access_sub_groups_parent_id_fk", :column => "parent_id"

  add_foreign_key "ninja_access_users_permissions", "ninja_access_permissions", :name => "ninja_access_users_permissions_permission_id_fk", :column => "permission_id"
  add_foreign_key "ninja_access_users_permissions", "users", :name => "ninja_access_users_permissions_user_id_fk"

end
