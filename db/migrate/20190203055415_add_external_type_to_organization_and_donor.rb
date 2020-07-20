class AddExternalTypeToOrganizationAndDonor < ActiveRecord::Migration[5.0][5.0]
  def change
    add_column :donors, :external_type, :string
    add_column :organizations, :external_type, :string
  end
end
