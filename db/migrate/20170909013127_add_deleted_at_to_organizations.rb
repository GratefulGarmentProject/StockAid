class AddDeletedAtToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :deleted_at, :datetime
  end
end
