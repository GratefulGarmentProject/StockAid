class CreateDonations < ActiveRecord::Migration
  def change
    create_table :donors do |t|
      t.string :name, null: false
      t.string :address
      t.string :email
      t.timestamps null: false
      t.index [:name], unique: true
    end

    create_table :donations do |t|
      t.references :user, foreign_key: true, null: false
      t.references :donor, foreign_key: true, null: false
      t.datetime :donation_date, null: false
      t.text :notes
      t.timestamps null: false
    end

    create_table :donation_details do |t|
      t.references :donation, foreign_key: true, null: false
      t.references :item, foreign_key: true, null: false
      t.integer :quantity, null: false
      t.decimal :value, precision: 8, scale: 2
      t.timestamps null: false
      t.index [:donation_id, :item_id]
      t.index [:donation_id]
    end
  end
end
