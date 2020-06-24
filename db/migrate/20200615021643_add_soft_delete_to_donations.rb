class AddSoftDeleteToDonations < ActiveRecord::Migration[5.0]
  def change
    add_column :donations, :deleted_at, :datetime
  end
end
