class UpdateUsersAndOrganizations < ActiveRecord::Migration
  def change
    rename_column :organizations, :email_address, :email
    add_column :users, :role, :string, null: false, default: "none"
  end
end
