class AddLocationDataToOrganization < ActiveRecord::Migration[5.0]
  def change
    add_column :organizations, :county, :string, null: true
    add_column :organizations, :latitude, :float, null: true
    add_column :organizations, :longitude, :float, null: true
  end
end
