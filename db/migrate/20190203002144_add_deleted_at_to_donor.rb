class AddDeletedAtToDonor < ActiveRecord::Migration[5.0]
  def change
    add_column :donors, :deleted_at, :datetime
  end
end
