class AddVendors < ActiveRecord::Migration[5.0]
  def change
    create_table :vendors do |t|
      t.string :name, null: false
      t.string :phone_number
      t.string :website
      t.string :email
      t.string :contact_name
      t.datetime :deleted_at
      t.timestamps null: false
      t.index [:name], unique: true
    end

    create_table :vendor_addresses do |t|
      t.references :vendor, foreign_key: true, null: false
      t.references :address, foreign_key: true, null: false
      t.timestamps null: false
      t.index [:vendor_id, :address_id], unique: true
    end
  end
end
