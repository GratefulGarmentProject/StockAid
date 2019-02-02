class CreateDonorAddresses < ActiveRecord::Migration[5.0]
  def change
    create_table :donor_addresses do |t|
      t.references :donor, foreign_key: true, null: false
      t.references :address, foreign_key: true, null: false
      t.timestamps null: false
      t.index [:donor_id, :address_id], unique: true
    end
  end
end
