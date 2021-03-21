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

ActiveRecord::Schema.define(version: 20210321171237) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", id: :serial, force: :cascade do |t|
    t.string "address", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "street_address"
    t.string "city", limit: 64
    t.string "state", limit: 32
    t.string "zip", limit: 16
  end

  create_table "bin_items", id: :serial, force: :cascade do |t|
    t.integer "bin_id", null: false
    t.integer "item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bin_id"], name: "index_bin_items_on_bin_id"
    t.index ["item_id"], name: "index_bin_items_on_item_id"
  end

  create_table "bin_locations", id: :serial, force: :cascade do |t|
    t.string "rack", null: false
    t.string "shelf", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rack", "shelf"], name: "index_bin_locations_on_rack_and_shelf", unique: true
  end

  create_table "bins", id: :serial, force: :cascade do |t|
    t.integer "bin_location_id", null: false
    t.string "label", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["bin_location_id"], name: "index_bins_on_bin_location_id"
    t.index ["label"], name: "index_bins_on_label"
  end

  create_table "categories", id: :serial, force: :cascade do |t|
    t.string "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "next_sku", default: 1, null: false
  end

  create_table "count_sheet_details", id: :serial, force: :cascade do |t|
    t.integer "count_sheet_id", null: false
    t.integer "item_id", null: false
    t.integer "counts", null: false, array: true
    t.integer "final_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["count_sheet_id", "item_id"], name: "index_count_sheet_details_on_count_sheet_id_and_item_id", unique: true
    t.index ["count_sheet_id"], name: "index_count_sheet_details_on_count_sheet_id"
    t.index ["item_id"], name: "index_count_sheet_details_on_item_id"
  end

  create_table "count_sheets", id: :serial, force: :cascade do |t|
    t.integer "inventory_reconciliation_id", null: false
    t.integer "bin_id"
    t.text "counter_names", default: [], null: false, array: true
    t.boolean "complete", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bin_id", "inventory_reconciliation_id"], name: "index_count_sheets_on_bin_id_and_inventory_reconciliation_id", unique: true
    t.index ["bin_id"], name: "index_count_sheets_on_bin_id"
    t.index ["inventory_reconciliation_id"], name: "index_count_sheets_on_inventory_reconciliation_id"
  end

  create_table "donation_details", id: :serial, force: :cascade do |t|
    t.integer "donation_id", null: false
    t.integer "item_id", null: false
    t.integer "quantity", null: false
    t.decimal "value", precision: 8, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["donation_id", "item_id"], name: "index_donation_details_on_donation_id_and_item_id"
    t.index ["donation_id"], name: "index_donation_details_on_donation_id"
    t.index ["item_id"], name: "index_donation_details_on_item_id"
  end

  create_table "donation_program_details", force: :cascade do |t|
    t.integer "donation_id", null: false
    t.integer "program_id", null: false
    t.decimal "value", precision: 8, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["donation_id", "program_id"], name: "index_donation_program_details_on_donation_id_and_program_id", unique: true
    t.index ["program_id"], name: "index_donation_program_details_on_program_id"
  end

  create_table "donations", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "donor_id", null: false
    t.datetime "donation_date", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer "external_id"
    t.datetime "closed_at"
    t.index ["donor_id"], name: "index_donations_on_donor_id"
    t.index ["user_id"], name: "index_donations_on_user_id"
  end

  create_table "donor_addresses", id: :serial, force: :cascade do |t|
    t.integer "donor_id", null: false
    t.integer "address_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address_id"], name: "index_donor_addresses_on_address_id"
    t.index ["donor_id", "address_id"], name: "index_donor_addresses_on_donor_id_and_address_id", unique: true
    t.index ["donor_id"], name: "index_donor_addresses_on_donor_id"
  end

  create_table "donors", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "secondary_number"
    t.integer "external_id"
    t.string "external_type"
    t.string "primary_number"
    t.index ["email"], name: "index_donors_on_email", unique: true
    t.index ["name"], name: "index_donors_on_name", unique: true
  end

  create_table "inventory_reconciliations", id: :serial, force: :cascade do |t|
    t.string "title"
    t.integer "user_id", null: false
    t.boolean "complete", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_inventory_reconciliations_on_user_id"
  end

  create_table "item_program_ratio_values", force: :cascade do |t|
    t.bigint "item_program_ratio_id", null: false
    t.bigint "program_id", null: false
    t.decimal "percentage", precision: 5, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_program_ratio_id"], name: "index_item_program_ratio_values_on_item_program_ratio_id"
    t.index ["program_id"], name: "index_item_program_ratio_values_on_program_id"
  end

  create_table "item_program_ratios", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "items", id: :serial, force: :cascade do |t|
    t.string "description", null: false
    t.integer "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "current_quantity", default: 0, null: false
    t.string "old_sku"
    t.decimal "value", default: "0.01", null: false
    t.datetime "deleted_at"
    t.integer "sku", null: false
    t.integer "item_program_ratio_id", null: false
    t.index ["category_id"], name: "index_items_on_category_id"
    t.index ["item_program_ratio_id"], name: "index_items_on_item_program_ratio_id"
    t.index ["sku"], name: "index_items_on_sku", unique: true
  end

  create_table "order_details", id: :serial, force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "quantity", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "item_id", null: false
    t.decimal "value", precision: 8, scale: 2
    t.integer "requested_quantity", default: 0, null: false
    t.index ["item_id"], name: "index_order_details_on_item_id"
    t.index ["order_id", "item_id"], name: "index_order_details_on_order_id_and_item_id", unique: true
    t.index ["order_id"], name: "index_order_details_on_order_id"
  end

  create_table "order_program_details", force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "program_id", null: false
    t.decimal "value", precision: 8, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id", "program_id"], name: "index_order_program_details_on_order_id_and_program_id", unique: true
    t.index ["program_id"], name: "index_order_program_details_on_program_id"
  end

  create_table "orders", id: :serial, force: :cascade do |t|
    t.integer "organization_id", null: false
    t.integer "user_id", null: false
    t.datetime "order_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", null: false
    t.string "ship_to_name"
    t.string "ship_to_address"
    t.string "notes"
    t.integer "external_id"
    t.datetime "closed_at"
    t.index ["organization_id"], name: "index_orders_on_organization_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "organization_addresses", id: :serial, force: :cascade do |t|
    t.integer "organization_id", null: false
    t.integer "address_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address_id"], name: "index_organization_addresses_on_address_id"
    t.index ["organization_id", "address_id"], name: "index_organization_addresses_on_organization_id_and_address_id", unique: true
    t.index ["organization_id"], name: "index_organization_addresses_on_organization_id"
  end

  create_table "organization_programs", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "program_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_organization_programs_on_organization_id"
    t.index ["program_id"], name: "index_organization_programs_on_program_id"
  end

  create_table "organization_users", id: :serial, force: :cascade do |t|
    t.integer "organization_id", null: false
    t.integer "user_id", null: false
    t.string "role", default: "none", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "user_id"], name: "index_organization_users_on_organization_id_and_user_id", unique: true
    t.index ["organization_id"], name: "index_organization_users_on_organization_id"
    t.index ["user_id"], name: "index_organization_users_on_user_id"
  end

  create_table "organizations", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "phone_number"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "county"
    t.datetime "deleted_at"
    t.integer "external_id"
    t.string "external_type"
    t.index ["name"], name: "index_organizations_on_name", unique: true
  end

  create_table "programs", force: :cascade do |t|
    t.string "name", null: false
    t.integer "external_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "external_class_id", null: false
  end

  create_table "purchase_details", id: :serial, force: :cascade do |t|
    t.integer "purchase_id", null: false
    t.integer "item_id", null: false
    t.integer "quantity", null: false, comment: "The quantity of items ordered"
    t.decimal "cost", precision: 8, scale: 2, comment: "Cost per item"
    t.decimal "variance", precision: 8, scale: 2, comment: "Variance between the Item value and the purchase item cost, calculated"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_purchase_details_on_item_id"
    t.index ["purchase_id", "item_id"], name: "index_purchase_details_on_purchase_id_and_item_id"
    t.index ["purchase_id"], name: "index_purchase_details_on_purchase_id"
  end

  create_table "purchase_shipments", id: :serial, force: :cascade do |t|
    t.integer "purchase_detail_id"
    t.integer "quantity_received", comment: "how many of the item came in the shipment"
    t.date "received_date", comment: "the date the shipment was received"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["purchase_detail_id"], name: "index_purchase_shipments_on_purchase_detail_id"
  end

  create_table "purchases", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "vendor_id", null: false
    t.string "vendor_po_number", comment: "Vendor Purchase Order Number, provided by Vendor"
    t.integer "status", null: false, comment: "Status order, state machine tracked"
    t.date "purchase_date", null: false
    t.decimal "shipping_cost", precision: 8, scale: 2, default: "0.0"
    t.decimal "tax", precision: 8, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "notes"
    t.index ["user_id"], name: "index_purchases_on_user_id"
    t.index ["vendor_id"], name: "index_purchases_on_vendor_id"
  end

  create_table "reconciliation_notes", id: :serial, force: :cascade do |t|
    t.integer "inventory_reconciliation_id", null: false
    t.integer "user_id", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inventory_reconciliation_id"], name: "index_reconciliation_notes_on_inventory_reconciliation_id"
    t.index ["user_id"], name: "index_reconciliation_notes_on_user_id"
  end

  create_table "reconciliation_unchanged_items", id: :serial, force: :cascade do |t|
    t.integer "inventory_reconciliation_id", null: false
    t.integer "user_id", null: false
    t.integer "item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inventory_reconciliation_id"], name: "rui_on_ir_id"
    t.index ["item_id"], name: "index_reconciliation_unchanged_items_on_item_id"
    t.index ["user_id"], name: "index_reconciliation_unchanged_items_on_user_id"
  end

  create_table "revenue_streams", force: :cascade do |t|
    t.integer "name"
    t.date "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tracking_details", id: :serial, force: :cascade do |t|
    t.integer "order_id"
    t.string "tracking_number"
    t.decimal "cost"
    t.date "date"
    t.date "delivery_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "shipping_carrier"
  end

  create_table "user_invitations", id: :serial, force: :cascade do |t|
    t.integer "organization_id", null: false
    t.string "email", null: false
    t.string "auth_token", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "invited_by_id", null: false
    t.string "name", null: false
    t.string "role", default: "none", null: false
    t.index ["auth_token"], name: "index_user_invitations_on_auth_token", unique: true
    t.index ["organization_id"], name: "index_user_invitations_on_organization_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "none", null: false
    t.string "name", null: false
    t.string "primary_number", null: false
    t.string "secondary_number"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "vendor_addresses", id: :serial, force: :cascade do |t|
    t.integer "vendor_id", null: false
    t.integer "address_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address_id"], name: "index_vendor_addresses_on_address_id"
    t.index ["vendor_id", "address_id"], name: "index_vendor_addresses_on_vendor_id_and_address_id", unique: true
    t.index ["vendor_id"], name: "index_vendor_addresses_on_vendor_id"
  end

  create_table "vendors", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "phone_number"
    t.string "website"
    t.string "email"
    t.string "contact_name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_vendors_on_name", unique: true
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.text "object_changes"
    t.datetime "created_at"
    t.integer "edit_amount"
    t.string "edit_method"
    t.string "edit_reason"
    t.string "edit_source"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "bin_items", "bins"
  add_foreign_key "bin_items", "items"
  add_foreign_key "bins", "bin_locations"
  add_foreign_key "count_sheet_details", "count_sheets"
  add_foreign_key "count_sheet_details", "items"
  add_foreign_key "count_sheets", "bins"
  add_foreign_key "count_sheets", "inventory_reconciliations"
  add_foreign_key "donation_details", "donations"
  add_foreign_key "donation_details", "items"
  add_foreign_key "donations", "donors"
  add_foreign_key "donations", "users"
  add_foreign_key "donor_addresses", "addresses"
  add_foreign_key "donor_addresses", "donors"
  add_foreign_key "inventory_reconciliations", "users"
  add_foreign_key "item_program_ratio_values", "item_program_ratios"
  add_foreign_key "item_program_ratio_values", "programs"
  add_foreign_key "items", "item_program_ratios"
  add_foreign_key "order_details", "items"
  add_foreign_key "organization_addresses", "addresses"
  add_foreign_key "organization_addresses", "organizations"
  add_foreign_key "organization_programs", "organizations"
  add_foreign_key "organization_programs", "programs"
  add_foreign_key "organization_users", "organizations"
  add_foreign_key "organization_users", "users"
  add_foreign_key "purchase_details", "items"
  add_foreign_key "purchase_details", "purchases"
  add_foreign_key "purchase_shipments", "purchase_details"
  add_foreign_key "purchases", "users"
  add_foreign_key "purchases", "vendors"
  add_foreign_key "reconciliation_notes", "inventory_reconciliations"
  add_foreign_key "reconciliation_notes", "users"
  add_foreign_key "reconciliation_unchanged_items", "inventory_reconciliations"
  add_foreign_key "reconciliation_unchanged_items", "items"
  add_foreign_key "reconciliation_unchanged_items", "users"
  add_foreign_key "user_invitations", "organizations"
  add_foreign_key "user_invitations", "users", column: "invited_by_id"
  add_foreign_key "vendor_addresses", "addresses"
  add_foreign_key "vendor_addresses", "vendors"
end
