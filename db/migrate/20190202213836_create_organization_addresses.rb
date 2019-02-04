class CreateOrganizationAddresses < ActiveRecord::Migration[5.0]
  def change
    create_table :organization_addresses do |t|
      t.references :organization, foreign_key: true, null: false
      t.references :address, foreign_key: true, null: false
      t.timestamps null: false
      t.index [:organization_id, :address_id], unique: true
    end
  end
end
