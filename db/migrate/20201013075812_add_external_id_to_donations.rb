class AddExternalIdToDonations < ActiveRecord::Migration[5.1]
  def change
    add_column :donations, :external_id, :integer
  end
end
