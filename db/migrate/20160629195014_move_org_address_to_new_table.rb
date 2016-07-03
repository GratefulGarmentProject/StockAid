class MoveOrgAddressToNewTable < ActiveRecord::Migration
  def change
    remove_column :organizations, :address, :string, null: false
    remove_column :organizations, :latitude, :float, null: true
    remove_column :organizations, :longitude, :float, null: true

    create_table :addresses do |t|
      t.references :organization, foreign_key: true, null: false
      t.string :address, null: false
      t.timestamps null: false
      t.index :organization_id
    end
  end
end
