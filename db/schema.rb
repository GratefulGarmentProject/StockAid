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

ActiveRecord::Schema.define(version: 20180110074208) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.integer  "organization_id", null: false
    t.string   "address",         null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "addresses", ["organization_id"], name: "index_addresses_on_organization_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "description", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "donation_details", force: :cascade do |t|
    t.integer  "donation_id",                         null: false
    t.integer  "item_id",                             null: false
    t.integer  "quantity",                            null: false
    t.decimal  "value",       precision: 8, scale: 2
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "donation_details", ["donation_id", "item_id"], name: "index_donation_details_on_donation_id_and_item_id", using: :btree
  add_index "donation_details", ["donation_id"], name: "index_donation_details_on_donation_id", using: :btree

  create_table "donations", force: :cascade do |t|
    t.integer  "user_id",       null: false
    t.integer  "donor_id",      null: false
    t.datetime "donation_date", null: false
    t.text     "notes"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "donors", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "address"
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "donors", ["email"], name: "index_donors_on_email", unique: true, using: :btree
  add_index "donors", ["name"], name: "index_donors_on_name", unique: true, using: :btree

  create_table "inventory_reconciliations", force: :cascade do |t|
    t.string   "title"
    t.integer  "user_id",                    null: false
    t.boolean  "complete",   default: false, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "items", force: :cascade do |t|
    t.string   "description",                                          null: false
    t.integer  "category_id",                                          null: false
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.integer  "current_quantity",                         default: 0, null: false
    t.string   "sku"
    t.decimal  "value",            precision: 8, scale: 2
    t.datetime "deleted_at"
  end

  create_table "order_details", force: :cascade do |t|
    t.integer  "order_id",                                               null: false
    t.integer  "quantity",                                               null: false
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.integer  "item_id",                                                null: false
    t.decimal  "value",              precision: 8, scale: 2
    t.integer  "requested_quantity",                         default: 0, null: false
  end

  add_index "order_details", ["order_id", "item_id"], name: "index_order_details_on_order_id_and_item_id", unique: true, using: :btree
  add_index "order_details", ["order_id"], name: "index_order_details_on_order_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "organization_id", null: false
    t.integer  "user_id",         null: false
    t.datetime "order_date",      null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "status",          null: false
    t.string   "ship_to_name"
    t.string   "ship_to_address"
  end

  create_table "organization_users", force: :cascade do |t|
    t.integer  "organization_id",                  null: false
    t.integer  "user_id",                          null: false
    t.string   "role",            default: "none", null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "organization_users", ["organization_id", "user_id"], name: "index_organization_users_on_organization_id_and_user_id", unique: true, using: :btree

  create_table "organizations", force: :cascade do |t|
    t.string   "name",         null: false
    t.string   "phone_number"
    t.string   "email"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "county"
    t.datetime "deleted_at"
  end

  add_index "organizations", ["name"], name: "index_organizations_on_name", unique: true, using: :btree

  create_table "reconciliation_notes", force: :cascade do |t|
    t.integer  "inventory_reconciliation_id", null: false
    t.integer  "user_id",                     null: false
    t.text     "content",                     null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "reconciliation_notes", ["inventory_reconciliation_id"], name: "index_reconciliation_notes_on_inventory_reconciliation_id", using: :btree

  create_table "reconciliation_unchanged_items", force: :cascade do |t|
    t.integer  "inventory_reconciliation_id", null: false
    t.integer  "user_id",                     null: false
    t.integer  "item_id",                     null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "reconciliation_unchanged_items", ["inventory_reconciliation_id"], name: "rui_on_ir_id", using: :btree

  create_table "shipments", force: :cascade do |t|
    t.integer  "order_id"
    t.string   "tracking_number"
    t.decimal  "cost"
    t.date     "date"
    t.date     "delivery_date"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "shipping_carrier"
  end

  create_table "user_invitations", force: :cascade do |t|
    t.integer  "organization_id",                  null: false
    t.string   "email",                            null: false
    t.string   "auth_token",                       null: false
    t.datetime "expires_at",                       null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "invited_by_id",                    null: false
    t.string   "name",                             null: false
    t.string   "role",            default: "none", null: false
  end

  add_index "user_invitations", ["auth_token"], name: "index_user_invitations_on_auth_token", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",     null: false
    t.string   "encrypted_password",     default: "",     null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,      null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.integer  "failed_attempts",        default: 0,      null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "role",                   default: "none", null: false
    t.string   "name",                                    null: false
    t.string   "primary_number",                          null: false
    t.string   "secondary_number"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.text     "object_changes"
    t.datetime "created_at"
    t.integer  "edit_amount"
    t.string   "edit_method"
    t.string   "edit_reason"
    t.string   "edit_source"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  add_foreign_key "addresses", "organizations"
  add_foreign_key "donation_details", "donations"
  add_foreign_key "donation_details", "items"
  add_foreign_key "donations", "donors"
  add_foreign_key "donations", "users"
  add_foreign_key "inventory_reconciliations", "users"
  add_foreign_key "order_details", "items"
  add_foreign_key "organization_users", "organizations"
  add_foreign_key "organization_users", "users"
  add_foreign_key "reconciliation_notes", "inventory_reconciliations"
  add_foreign_key "reconciliation_notes", "users"
  add_foreign_key "reconciliation_unchanged_items", "inventory_reconciliations"
  add_foreign_key "reconciliation_unchanged_items", "items"
  add_foreign_key "reconciliation_unchanged_items", "users"
  add_foreign_key "user_invitations", "organizations"
  add_foreign_key "user_invitations", "users", column: "invited_by_id"
end
