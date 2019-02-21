class AddExternalIdToDonorAndOrganization < ActiveRecord::Migration[5.0]
  def change
    add_column :donors, :external_id, :integer
    add_column :organizations, :external_id, :integer
  end
end
