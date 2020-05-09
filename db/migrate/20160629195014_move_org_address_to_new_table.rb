class MoveOrgAddressToNewTable < ActiveRecord::Migration[5.0]
  def change
    remove_column :organizations, :address, :string, null: false
    remove_column :organizations, :latitude, :float, null: true
    remove_column :organizations, :longitude, :float, null: true

    create_table :addresses do |t|
      t.references :organization, foreign_key: true, null: false
      t.string :address, null: false
      t.timestamps null: false
      # In rails 5.2 the creation of references in table creation defaults to create this index
      # t.index :organization_id
    end
  end
end
